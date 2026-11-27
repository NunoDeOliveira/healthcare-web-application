"""Preview and deploy the MediCore Azure workload."""

import argparse
import json
import os
import shlex
import subprocess
import sys
import time
from getpass import getpass
from pathlib import Path


#####################################################################
# Configuration
#####################################################################

PARAMETERS = Path(__file__).resolve().parents[1] / 'parameters/workload.bicepparam'
PARENT = 'medicore-workload'
CHILD = 'deploy-app-service-plan'
GROUP = 'rg-medicore-app'
ACTIVE = ('Running', 'Accepted')
FINISHED = ('Succeeded', 'Failed', 'Canceled')
POLL_SECONDS = 30
MAX_FAILURES = 3


#####################################################################
# Run Azure CLI commands written like terminal commands
#####################################################################

def az(command, missing_ok=False):
    result = subprocess.run(
        shlex.split(command),
        capture_output=True,
        text=True
    )

    if result.returncode != 0:
        if missing_ok and any(
            code in result.stderr
            for code in ('DeploymentNotFound', 'ResourceNotFound')
        ):
            return None

        raise RuntimeError(result.stderr.strip() or 'Azure CLI command failed.')

    return json.loads(result.stdout) if result.stdout.strip() else {}


#####################################################################
# Read the current deployment status
#####################################################################

def deployment(subscription, kind):
    if kind == 'sub':
        command = f"""
        az deployment sub show
          --name {PARENT}
          --subscription {subscription}
          --output json
        """
    else:
        command = f"""
        az deployment group show
          --resource-group {GROUP}
          --name {CHILD}
          --subscription {subscription}
          --output json
        """

    return az(command, missing_ok=True)


def state(item):
    if item is None:
        return None
    return item['properties']['provisioningState']


#####################################################################
# Read Failed events for one deployment correlation ID
#####################################################################

def failures(subscription, correlation_id, kind):
    command = f"""
    az monitor activity-log list
      --correlation-id {correlation_id}
      --offset 7d
      --max-events 1000
      --subscription {subscription}
      --output json
    """

    if kind == 'group':
        command += f' --resource-group {GROUP}'

    events = az(command)
    result = {}

    for event in events:
        if event.get('status', {}).get('value') != 'Failed':
            continue

        event_id = event.get('eventDataId') or event.get('id')
        if not event_id:
            raise RuntimeError('A Failed activity-log event has no event ID.')

        result[event_id] = event

    return result


def error_details(event):
    http_code = event.get('subStatus', {}).get('value', 'Unknown')
    raw_message = event.get('properties', {}).get('statusMessage', '')

    if isinstance(raw_message, str):
        try:
            raw_message = json.loads(raw_message)
        except (ValueError, TypeError):
            return http_code, raw_message or 'No error message available.'

    if isinstance(raw_message, dict):
        error = raw_message.get('error', raw_message)
        if isinstance(error, dict):
            code = error.get('code') or http_code
            message = error.get('message') or str(raw_message)
            return code, message

    return http_code, str(raw_message)


#####################################################################
# Cancel active deployments and verify the cancellation
#####################################################################

def cancel(subscription):
    child = deployment(subscription, 'group')
    if state(child) in ACTIVE:
        print('Requesting App Service Plan cancellation...', flush=True)
        az(f"""
        az deployment group cancel
          --resource-group {GROUP}
          --name {CHILD}
          --subscription {subscription}
        """)

    parent = deployment(subscription, 'sub')
    if state(parent) in ACTIVE:
        print('Requesting workload cancellation...', flush=True)
        az(f"""
        az deployment sub cancel
          --name {PARENT}
          --subscription {subscription}
        """)

    for attempt in range(12):
        parent_state = state(deployment(subscription, 'sub'))
        child_state = state(deployment(subscription, 'group'))

        if parent_state not in ACTIVE and child_state not in ACTIVE:
            print(f'Final states: workload={parent_state}, plan={child_state}', flush=True)
            return

        time.sleep(10)

    print('WARNING: cancellation requested but not yet confirmed.', flush=True)


#####################################################################
# Monitor current deployments until Azure reports a final status
#####################################################################

def monitor(subscription, started_new=False):
    printed = set()
    known_failures = {}
    tracked_ids = {}
    child_was_active = False
    deployment_seen = False
    parent_was_active = started_new
    missing_checks = 0

    while True:
        parent = deployment(subscription, 'sub')
        child = deployment(subscription, 'group')
        parent_state = state(parent)
        child_state = state(child)

        if parent is not None and (started_new or parent_state in ACTIVE):
            parent_was_active = True

        if (parent_was_active and parent is not None) or child_state in ACTIVE:
            deployment_seen = True

        if child_state in ACTIVE:
            child_was_active = True

        if parent_was_active and parent is not None:
            correlation = parent['properties'].get('correlationId')
            if not correlation:
                raise RuntimeError('Workload deployment has no correlationId.')
            tracked_ids['sub'] = correlation

        if child_was_active and child is not None:
            correlation = child['properties'].get('correlationId')
            if not correlation:
                raise RuntimeError('App Service Plan deployment has no correlationId.')
            tracked_ids['group'] = correlation

        for kind, correlation_id in tracked_ids.items():
            events = failures(subscription, correlation_id, kind)
            known_failures.update(events)

        for event_id, event in known_failures.items():
            if event_id not in printed:
                code, message = error_details(event)
                operation = event.get('operationName', {}).get('value', 'Unknown')
                print(f'FAILED [{code}] {operation}: {message[:500]}', flush=True)
                printed.add(event_id)

        print(
            f'Workload: {parent_state} | App Service Plan: {child_state} '
            f'| Failed events: {len(known_failures)}/{MAX_FAILURES}',
            flush=True
        )

        if len(known_failures) >= MAX_FAILURES:
            print('Failure limit reached. Requesting cancellation...', flush=True)
            cancel(subscription)
            return 1

        if not deployment_seen:
            missing_checks += 1
            if missing_checks >= 10:
                raise RuntimeError('Deployment not found after starting it.')
        else:
            parent_finished = not parent_was_active or parent_state in FINISHED
            child_finished = not child_was_active or child_state in FINISHED

            if parent_finished and child_finished:
                if (parent_was_active and parent_state == 'Failed') or (child_was_active and child_state == 'Failed'):
                    print('Final result: Failed.', flush=True)
                    return 1
                if (parent_was_active and parent_state == 'Canceled') or (child_was_active and child_state == 'Canceled'):
                    print('Final result: Canceled.', flush=True)
                    return 1
                if ((parent_was_active and parent_state == 'Succeeded')
                        or (child_was_active and child_state == 'Succeeded')):
                    print('Final result: Succeeded.', flush=True)
                    return 0

        time.sleep(POLL_SECONDS)


#####################################################################
# Validate subscription and preview the deployment
#####################################################################

def run():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--execute', action='store_true')
    args = parser.parse_args()

    if not PARAMETERS.is_file():
        raise RuntimeError(f'Missing parameter file: {PARAMETERS}')

    account = az('az account show --output json')
    if account['name'] != 'Azure for Students':
        raise RuntimeError(f'Wrong subscription: {account["name"]}')

    subscription = account['id']
    print('Subscription: Azure for Students', flush=True)

    environment = os.environ.copy()
    if args.execute:
        password = getpass('Azure SQL administrator password: ')
        if not password:
            raise RuntimeError('SQL administrator password cannot be empty.')
        environment['MEDICORE_SQL_ADMIN_PASSWORD'] = password
        del password

    command = f"""
    az deployment sub what-if
      --subscription {subscription}
      --location spaincentral
      --parameters {shlex.quote(str(PARAMETERS))}
    """

    print('\nWHAT-IF:', flush=True)
    subprocess.run(shlex.split(command), check=True, env=environment)

    if not args.execute:
        print('Preview only. No deployment started.', flush=True)
        return 0

    if input('Type DEPLOY WORKLOAD to continue: ').strip() != 'DEPLOY WORKLOAD':
        print('Deployment cancelled by user.', flush=True)
        return 0

    #####################################################################
    # Resume an active deployment or start a new one
    #####################################################################

    parent = deployment(subscription, 'sub')
    child = deployment(subscription, 'group')

    started_new = False
    if state(parent) in ACTIVE or state(child) in ACTIVE:
        print('Active deployment found. Monitoring without restarting.', flush=True)
    else:
        command = f"""
        az deployment sub create
          --name {PARENT}
          --subscription {subscription}
          --location spaincentral
          --parameters {shlex.quote(str(PARAMETERS))}
          --no-wait
        """

        print('\nSTART DEPLOYMENT:', flush=True)
        subprocess.run(shlex.split(command), check=True, env=environment)
        started_new = True

    return monitor(subscription, started_new)


#####################################################################
# Error handling
#####################################################################

if __name__ == '__main__':
    try:
        sys.exit(run())
    except (RuntimeError, subprocess.CalledProcessError, FileNotFoundError) as error:
        print(f'ERROR: {error}', file=sys.stderr)
        sys.exit(1)
    except KeyboardInterrupt:
        print('Monitoring stopped. Azure deployment may still be active.', file=sys.stderr)
        sys.exit(130)
