#!/bin/bash
set -e

# Define the required environment variables
required_env_vars=("ENV0_ORG_ID" "TFC_ORG_NAME")

# Function to check if an environment variable is set
check_env_var() {
  if [ -z "${!1}" ]; then
    echo "Error: $1 is not set."
    exit 1
  fi
}

# Check each required environment variable
for env_var in "${required_env_vars[@]}"; do
  check_env_var "$env_var"
done

# filter WS names from the json input
workspaces=$(cat "../out/data.json" | jq -r '.workspaces[] | select(.type == "terraform") | .name')

# loop through the workspaces
for workspace in ${workspaces[@]}; do
  ./migrate_single_workspace.sh "$workspace"
done
