# Migrate from TFC 

## Usage

1. create an `exporter.tfvars` file with the following content:

```hcl
tfc_token = "your-tfc-token"
tfc_organization = "your-tfc-organization"
```
you may also specify the following optional variables:
```hcl
tfc_workspace_names = ["array of workspace names to export", "wildcards supported"]
tfc_workspace_include_tags = ["array of tags to include", "wildcards are not supported"]
tfc_workspace_exclude_tags = ["array of tags to exclude", "wildcards are not supported"]
```

Note: names and tags are applied together, "with AND operator". exclude tags take precedence over include tags and names.

2. run the exporter:
```bash
terraform init
terraform apply -var-file=exporter.tfvars
```

3. create the environments in env0:
go to the `env0-resources-generator` folder and run:
```bash
# generate the env0 resources terraform files
terraform init
terraform apply -var-file=../TFC/out/data.json 

# create the env0 resources
cd out
terraform init
terraform apply
```

Note: you'll need to have the env0 credentials set as environment variables. See [here](https://docs.env0.com/reference/authentication#creating-a-personal-api-key)  about env0 API keys


4. import the workspaces to env0:
go to the `TFC/migrate-state` folder and run:
```bash
./migrate_workspaces.sh
```

Note: you'll need to have the env0 credentials set as environment variables and to be logged into Terraform CLI in order to run the above command. In addition, the following environment variables are required:
- `ENV0_ORG_ID` - env0 organization id 
- `TFC_ORG_NAME` - organization name in TFC
- `ENV0_HOSTNAME` - (Optional) the remote backend URL of env0. `backend.api.env0.com` is used by default 

the script is supported only for Terraform version <1.6.0

See `migrate-state/README.md` for more details about this phase

## Supported workspaces for migration

Currently the tool will only migrate VCS integrated workspaces, and the migration will be successful only for Github repositories.
Workspaces that use Terraform versions >=1.6.0, will be using OpenTofu in env0.
