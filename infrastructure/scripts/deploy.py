"""Preview or deploy only the MediCore workload (never foundation)."""

import argparse
import json
import subprocess
import sys
from pathlib import Path

INFRA = Path(__file__).resolve().parents[1]
PARAMETERS = INFRA / 'parameters' / 'workload.bicepparam'


def az(*args, capture=False):
    result = subprocess.run(['az', *args], check=True, text=True,
                            capture_output=capture)
    return result.stdout.strip() if capture else None


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--execute', action='store_true',
                        help='Deploy workload after a what-if preview')
    args = parser.parse_args()

    if not PARAMETERS.is_file():
        parser.error(f'Missing parameter file: {PARAMETERS}')

    account = json.loads(az('account', 'show', '-o', 'json', capture=True))
    subscription = account['id']
    print(f"Subscription: {account['name']} ({subscription})", flush=True)

    common = [
        '--subscription', subscription,
        '--location', 'spaincentral',
        '--parameters', str(PARAMETERS),
    ]

    print('\nWorkload what-if:', flush=True)
    az('deployment', 'sub', 'what-if', *common)

    if not args.execute:
        print('\nPreview only. Use --execute to deploy workload.')
        return

    if input('Type DEPLOY WORKLOAD to continue: ').strip() != 'DEPLOY WORKLOAD':
        print('Cancelled.')
        return

    az('deployment', 'sub', 'create', '--name', 'medicore-workload', *common)
    print('Workload deployment completed.')


if __name__ == '__main__':
    try:
        main()
    except (subprocess.CalledProcessError, FileNotFoundError) as exc:
        print(f'Error: {exc}', file=sys.stderr)
        sys.exit(1)
