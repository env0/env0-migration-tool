data "http" "projects" {
  url             = "https://app.terraform.io/api/v2/organizations/${var.tfc_organization}/projects?page[size]=100"
  request_headers = {
    Authorization = "Bearer ${var.tfc_token}"
  }
}

data "tfe_workspace_ids" "all" {
  exclude_tags = var.tfc_workspace_exclude_tags
  names        = var.tfc_workspace_names
  organization = var.tfc_organization
  tag_names    = var.tfc_workspace_include_tags
}

data "tfe_workspace" "all" {
  for_each = toset(local.workspace_names)

  name         = each.key
  organization = var.tfc_organization
}

data "tfe_variables" "all" {
  for_each = toset(local.workspaces_ids)

  workspace_id = each.key
}
