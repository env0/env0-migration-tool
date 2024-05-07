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

# set the env0 credentials as environment variables or under the provider block in the `main.tf` file as explained here - https://registry.terraform.io/providers/env0/env0/latest/docs
terraform apply
```

Note: you'll need to have the env0 credentials set as environment variables. See [here](https://docs.env0.com/reference/authentication#creating-a-personal-api-key) about env0 API keys

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

## VCS Connection

By default, all of the imported workspaces won't be connected automatically to a VCS. in order to do so, you will have to include the "include_vcs_connection" variable to the code generator TF stack.

1. Before running `terraform apply -var-file=../TFC/out/data.json`, add the following variable

```bash
terraform apply -var-file=../TFC/out/data.json -var="include_vcs_connection=true"
```

2. You will notice a new file called `vcs.tf` is created

```hcl
data "env0_template" "vcs_connected_template" {
  name = "Name Of VCS Connected Template"
}

locals {
  bitbucket_client_key   = data.env0_template.vcs_connected_template.bitbucket_client_key
  github_installation_id = data.env0_template.vcs_connected_template.github_installation_id
  token_id               = data.env0_template.vcs_connected_template.token_id
  is_bitbucket_server    = data.env0_template.vcs_connected_template.is_bitbucket_server
  is_github_enterprise   = data.env0_template.vcs_connected_template.is_github_enterprise
  is_gitlab_enterprise   = data.env0_template.vcs_connected_template.is_gitlab_enterprise
  ssh_keys               = data.env0_template.vcs_connected_template.ssh_keys
}
```

3. Go to env0 UI and create a vcs connected template, give it a unique name like "vcs-connection".
4. After creating this template, replace `"Name Of VCS Connected Template"` with the new template's name.
5. Resume with the import process.

_DISCLAIMER_
This utility will provide you a nicer way to connect to a single organization on your vcs. In case you have multiple connections for your imported environments, you might need to manually configure them (in a similar way)

### Modules

NOTE: in case you have modules imported as well, those steps are mandatory as modules are required to be vcs integrated. If you won't include the `include_vcs_connection`, However, this connection won't be applicable to you imported workspaces.
