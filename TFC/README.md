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
