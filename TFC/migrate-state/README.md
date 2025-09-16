# Migrate State into env0

This action will migrate state from one TFC workspace to an env0 environment.

## Pre-requisites

- A TFC organization
- An env0 organization
- Terraform CLI logged in (`terraform login`)
- Terraform version < 1.6.0
- Export `ENV0_API_KEY` and `ENV0_API_SECRET` as environment variables

## Inputs

- `ENV0_ORG_ID`: env0 organization id
- `TFC_ORG_NAME`: organization name in TFC
- `ENV0_API_KEY` and `ENV0_API_SECRET`: env0 personal API key and secret
- `ENV0_HOSTNAME` (optional): env0 backend hostname. Defaults to `backend.api.env0.com`
- `TFC_HOSTNAME`: organization name in TFC, if not set will default to "app.terraform.io"

## Usage

From the `TFC/migrate-state/` directory, run one of the following:

```bash
# migrate all Terraform workspaces found in ../out/data.json
./migrate_workspaces.sh

# migrate a single workspace by name (use this if only one workspace is being migrated)
./migrate_single_workspace.sh <WORKSPACE_NAME>
```

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
