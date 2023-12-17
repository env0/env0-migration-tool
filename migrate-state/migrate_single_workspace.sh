#!/bin/bash

# Define the required environment variables
required_env_vars=("ENV0_ORG_ID" "TFC_ORG_NAME" "WS_NAME" "ENV0_HOSTNAME")

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

# Create a directory based on WS_NAME
ws_directory="./$WS_NAME"
mkdir -p "$ws_directory"

# Check if the directory was created successfully
if [ $? -ne 0 ]; then
  echo "Error creating directory: $ws_directory"
  exit 1
fi

cd "$ws_directory" || exit

# Source file and destination file for TFC configuration
tfc_source_file="../tfc_template"
tfc_destination_file="tfc.main.tf"

# Create a copy of the source file with replacements
sed -e "s|!!!TFC_ORG_NAME!!!|${TFC_ORG_NAME}|g" \
  -e "s|!!!WS_NAME!!!|${WS_NAME}|g" \
  "$tfc_source_file" >"$tfc_destination_file"

# Check if the destination file was created successfully
if [ $? -ne 0 ]; then
  echo "Error creating file: $tfc_destination_file"
  exit 1
fi

echo "Initializing Terraform with TFC backend and pulling state"

# pull TF state
terraform init
terraform state pull > tfc.tfstate

echo "Pulled Terraform state from TFC"


# remove .terraform folder and tfc.main.tf
rm -rf .terraform
rm tfc.main.tf

# Source file and destination file for Env0 configuration
env0_source_file="../env0_template"
env0_destination_file="env0.tf"

# Create a copy of the source file with replacements
sed -e "s|!!!ENV0_ORG_ID!!!|${ENV0_ORG_ID}|g" \
  -e "s|!!!ENV0_HOSTNAME!!!|${ENV0_HOSTNAME}|g" \
  -e "s|!!!WS_NAME!!!|${WS_NAME}|g" \
  "$env0_source_file" >"$env0_destination_file"

# Check if the destination file was created successfully
if [ $? -ne 0 ]; then
  echo "Error creating file: $env0_destination_file"
  exit 1
fi

echo "Initializing Terraform with env0 backend and pushing state"

# push TF state
terraform init
terraform state push -ignore-remote-version -force tfc.tfstate

# cleanup
cd ..
rm -rf "$ws_directory"
