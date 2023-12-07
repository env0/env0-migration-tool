# Migrate from TFC 

## Usage

1. create an `exporter.tfvars` file with the following content:

```hcl
tfc_token = "your-tfc-token"
tfc_organization = "your-tfc-organization"
```

2. run the exporter:
```bash
terraform init
terraform apply -var-file=exporter.tfvars
```
