# Migrate State into env0

This action will migrate state from one TFC workspace to an env0 environment.

## Pre-requisites

- A TFC organization
- An env0 organization
- Being logged in to TFC using `terraform login`
- Export `ENV0_API_KEY` and `ENV0_API_SECRET` as environment variables

## Inputs

- `ENV0_ORG_ID`: env0 organization id
- `TFC_ORG_NAME`: organization name in TFC

## Usage

1. run `./migrate_workspaces.sh`

## How does it work?

For each workspace, the script will run the `migrate_single_workspace.sh` script, which in turn will:
- create a new directory for the workspace
- download the state file from TFC
- upload the state file to env0
- clean up the directory

## Note

- only workspaces with Terraform version <1.6.0 are supported. the remote version of the workspace and environment is irrelevant, we use `ignore_remote_version` when pushing the state
- only Terraform <1.6.0 will manage to run the script
- the script overrides existing workspaces in env0!
- If you run into any problems, check out this [Troubleshooting Guide](./troubleshooting-guide.md) for solutions. 
