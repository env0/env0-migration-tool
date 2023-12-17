# Migrate State into env0

This action will migrate state from one TFC workspace to an env0 environment.

## Pre-requisites

- A TFC organization
- An env0 organization
- Being logged in to TFC using `terraform login`
- Export `ENV0_API_KEY` and `ENV0_API_SECRET` as environment variables

## Inputs

- tfc_org_name: The name of the TFC organization
- env0_org_id: The ID of the env0 organization
- workspaces: A list of workspaces to migrate. You should use the exported workspaces from the `TFC/out` folder
- env0_hostname: (override for development purposes only) url for env0's remote backend

## Usage

1. run `terraform init` in the `migrate-state` folder
2. run `terraform apply` in the `migrate-state` folder

## How does it work?

For each workspace, the action will run the `migrate_single_workspace.sh` script. This script will:
- create a new directory for the workspace
- download the state file from TFC
- upload the state file to env0
- clean up the directory

## Note

- only workspaces with Terraform version <1.6.0 are supported
