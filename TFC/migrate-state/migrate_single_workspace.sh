#!/bin/bash
set -e

WS_NAME=$1

echo "-------"
echo "Migrating state for workspace: $WS_NAME"
echo "-------"

# Create a directory based on WS_NAME
ws_directory="./$WS_NAME"
mkdir -p "$ws_directory"

cd "$ws_directory" || exit

# Source file and destination file for TFC configuration
tfc_source_file="../tfc_template"
tfc_destination_file="tfc.main.tf"

# Create a copy of the source file with replacements
sed -e "s|!!!TFC_ORG_NAME!!!|${TFC_ORG_NAME}|g" \
  -e "s|!!!WS_NAME!!!|$WS_NAME|g" \
  "$tfc_source_file" >"$tfc_destination_file"

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
  -e "s|!!!ENV0_HOSTNAME!!!|${ENV0_HOSTNAME:="backend.api.env0.com"}|g" \
  -e "s|!!!WS_NAME!!!|$WS_NAME|g" \
  "$env0_source_file" >"$env0_destination_file"

echo "Initializing Terraform with env0 backend and pushing state"

# push TF state
terraform init
terraform state push -ignore-remote-version -force tfc.tfstate

# cleanup
cd ..
rm -rf "$ws_directory"
