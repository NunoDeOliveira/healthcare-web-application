# This file allows to destroy the resouces in the workload directory

import subprocess

rg_name = "rg-medicore-net"

# Check Azure authentication
subprocess.run(["az", "account", "show", "-o", "none"], check=True)

# Check resource group
result = subprocess.run(
    ["az", "group", "exists", "--name", rg_name],
    capture_output=True,
    text=True,
    check=True
)

if result.stdout.strip() == "true":

    # List resources
    subprocess.run(
        ["az", "resource", "list", "-g", rg_name, "-o", "table"],
        check=True
    )

    # Confirm deletion
    if input("Delete resource group? (yes/no): ") == "yes":

        subprocess.run(
            ["az", "group", "delete", "-n", rg_name, "--yes"],
            check=True
        )

        print("Resource group deleted.")

else:
    print("Resource group not found.")
