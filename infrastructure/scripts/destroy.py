"""Safely preview or delete dedicated MediCore workload resource groups."""

import argparse
import json
import subprocess
import sys

RESOURCE_GROUPS = (
    "rg-medicore-app",
    "rg-medicore-net",
    "rg-medicore-monitor",
)
EXPECTED_PROJECT_TAG = "p01-web"


def az(*args, capture=False):
    result = subprocess.run(
        ["az", *args], check=True, text=True,
        capture_output=capture,
    )
    return result.stdout.strip() if capture else None


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--execute", action="store_true", help="Delete all three dedicated resource groups")
    args = parser.parse_args()

    account = json.loads(az("account", "show", "--output", "json", capture=True))
    subscription = account["id"]
    print(f"Azure subscription: {account['name']} ({subscription})", flush=True)

    existing = []
    for group in RESOURCE_GROUPS:
        exists = az("group", "exists", "--name", group,
                    "--subscription", subscription, "--output", "tsv", capture=True)
        if exists.lower() != "true":
            print(f"Not found: {group}")
            continue
        info = json.loads(az("group", "show", "--name", group,
                             "--subscription", subscription, "--output", "json", capture=True))
        if (info.get("tags") or {}).get("Project") != EXPECTED_PROJECT_TAG:
            parser.error(f"Refusing deletion: {group} does not have Project={EXPECTED_PROJECT_TAG}")
        existing.append(group)
        print(f"\nResources in {group}:", flush=True)
        az("resource", "list", "--resource-group", group,
           "--subscription", subscription, "--output", "table")

    if not existing:
        print("No MediCore resource groups found.")
        return

    if not args.execute:
        print("\nPreview only. Use --execute to request deletion of ALL listed resource groups.")
        return

    print("\nWARNING: This permanently deletes all resources in the listed groups.")
    print("This may also delete data. Resources outside these groups are not checked.")
    if input(f"Type DELETE {subscription} to confirm: ").strip() != f"DELETE {subscription}":
        print("Cancelled.")
        return

    for group in existing:
        print(f"Deleting {group} ...", flush=True)
        az("group", "delete", "--name", group, "--subscription", subscription, "--yes")
    print("Resource-group deletion commands completed.")


if __name__ == "__main__":
    try:
        main()
    except (subprocess.CalledProcessError, FileNotFoundError) as exc:
        print(f"Error: {exc}", file=sys.stderr)
        sys.exit(1)
