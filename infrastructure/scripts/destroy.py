"""Preview or delete only the MediCore workload resource groups."""

import argparse
import json
import shlex
import subprocess
import sys
from getpass import getpass


#####################################################################
# Configuration
#####################################################################

RESOURCE_GROUPS = (
    'rg-medicore-app',
    'rg-medicore-net',
    'rg-medicore-monitor',
)
EXPECTED_PROJECT_TAG = 'p01-web'


#####################################################################
# Execute Azure CLI commands
#####################################################################

def az(command):
    result = subprocess.run(
        shlex.split(command),
        capture_output=True,
        text=True,
        check=True
    )
    return result.stdout.strip()


#####################################################################
# Verify subscription and preview the resources to delete
#####################################################################

def run():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--execute', action='store_true')
    args = parser.parse_args()

    account = json.loads(az('az account show --output json'))
    if account['name'] != 'Azure for Students':
        raise RuntimeError(f'Wrong subscription: {account["name"]}')

    subscription = account['id']
    print(f'Azure subscription: {account["name"]}', flush=True)

    existing = []

    for group in RESOURCE_GROUPS:
        command = f"""
        az group exists
          --name {group}
          --subscription {subscription}
        """
        if az(command).lower() != 'true':
            print(f'Not found: {group}')
            continue

        command = f"""
        az group show
          --name {group}
          --subscription {subscription}
          --output json
        """
        info = json.loads(az(command))
        project_tag = (info.get('tags') or {}).get('Project')

        if project_tag != EXPECTED_PROJECT_TAG:
            raise RuntimeError(f'Wrong Project tag in {group}. Nothing was deleted.')

        existing.append(group)

        command = f"""
        az resource list
          --resource-group {group}
          --subscription {subscription}
          --query '[].{{Name:name,Type:type}}'
          --output table
        """
        print(f'\nResources in {group}:')
        print(az(command) or 'No resources.')

    if not existing:
        print('No MediCore resource groups found.')
        return 0

    if not args.execute:
        print('\nPreview only. No resources deleted.')
        return 0

    #####################################################################
    # Block deletion while a MediCore deployment is running
    #####################################################################

    command = f"""
    az deployment sub list
      --subscription {subscription}
      --query "[?name=='medicore-workload' && (properties.provisioningState=='Running' || properties.provisioningState=='Accepted')].name"
      --output json
    """
    active_parent = json.loads(az(command))

    command = f"""
    az deployment group list
      --resource-group rg-medicore-app
      --subscription {subscription}
      --query "[?name=='deploy-app-service-plan' && (properties.provisioningState=='Running' || properties.provisioningState=='Accepted')].name"
      --output json
    """
    active_child = json.loads(az(command)) if 'rg-medicore-app' in existing else []

    if active_parent or active_child:
        raise RuntimeError('MediCore deployment is active. Deletion blocked.')

    #####################################################################
    # Require explicit confirmation before deletion
    #####################################################################

    print('\nWARNING: All resources and data in these groups will be deleted.')
    print('Resource groups:', ', '.join(existing))

    confirmation = getpass('Enter your Azure subscription ID to confirm deletion: ').strip()
    if confirmation != subscription:
        print('Incorrect subscription ID. No resources deleted.')
        return 1

    #####################################################################
    # Delete only validated MediCore resource groups
    #####################################################################

    for group in existing:
        command = f"""
        az group delete
          --name {group}
          --subscription {subscription}
          --yes
        """
        print(f'\nDeleting {group}...', flush=True)
        az(command)

    print('\nResource groups deleted successfully.')
    return 0


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
        print('Deletion interrupted. Check Azure before retrying.', file=sys.stderr)
        sys.exit(130)
