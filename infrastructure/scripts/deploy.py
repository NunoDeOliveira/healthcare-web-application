"""Preview or deploy only the MediCore workload (never foundation)."""

import argparse
import json
import os
import subprocess
import sys

from getpass import getpass
from pathlib import Path


INFRA = Path(__file__).resolve().parents[1]
PARAMETERS = INFRA / "parameters" / "workload.bicepparam"


def az(*args, capture=False, env=None):
    result = subprocess.run(
        ["az", *args],
        check=True,
        text=True,
        capture_output=capture,
        env=env,
    )

    return result.stdout.strip() if capture else None


def main():
    parser = argparse.ArgumentParser(description=__doc__)

    parser.add_argument(
        "--execute",
        action="store_true",
        help="Deploy workload after a what-if preview",
    )

    args = parser.parse_args()

    if not PARAMETERS.is_file():
        parser.error(f"Missing parameter file: {PARAMETERS}")

    # Get Azure subscription
    account = json.loads(
        az("account", "show", "-o", "json", capture=True)
    )

    subscription = account["id"]

    print(
        f"Subscription: {account['name']} ({subscription})",
        flush=True,
    )

    # Prepare environment variables
    deployment_env = os.environ.copy()

    if args.execute:
        # Request SQL password without displaying it
        sql_password = getpass(
            "Azure SQL administrator password: "
        )

        if not sql_password:
            parser.error("SQL administrator password cannot be empty.")

        deployment_env["MEDICORE_SQL_ADMIN_PASSWORD"] = sql_password

        del sql_password

    # Common deployment parameters
    common = [
        "--subscription", subscription,
        "--location", "spaincentral",
        "--parameters", str(PARAMETERS),
    ]

    # Preview deployment
    print("\nWorkload what-if:", flush=True)

    az(
        "deployment",
        "sub",
        "what-if",
        *common,
        env=deployment_env,
    )

    if not args.execute:
        print(
            "\nPreview only. Use --execute to deploy workload."
        )
        return

    # Require explicit confirmation
    confirmation = input(
        "Type DEPLOY WORKLOAD to continue: "
    ).strip()

    if confirmation != "DEPLOY WORKLOAD":
        print("Cancelled.")
        return

    # Deploy workload
    az(
        "deployment",
        "sub",
        "create",
        "--name", "medicore-workload",
        *common,
        env=deployment_env,
    )

    print("Workload deployment completed.")


if __name__ == "__main__":
    try:
        main()

    except (subprocess.CalledProcessError, FileNotFoundError) as exc:
        print(f"Error: {exc}", file=sys.stderr)
        sys.exit(1)
