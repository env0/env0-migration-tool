provider "null" {}

locals {
  terraform_workspaces = [for workspace in var.workspaces : workspace.name if workspace.type == "terraform"]
}

resource "null_resource" "invoke_migration_script" {
  for_each = toset(local.terraform_workspaces)
  provisioner "local-exec" {
    command     = "./migrate_single_workspace.sh"
    environment = {
      ENV0_ORG_ID = var.env0_org_id
      TFC_ORG_NAME  = var.tfc_org_name
      WS_NAME       = each.value
      ENV0_HOSTNAME = var.env0_hostname
    }
  }
}
