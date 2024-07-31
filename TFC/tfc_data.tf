data "http" "projects" {
  url             = "https://app.terraform.io/api/v2/organizations/${var.tfc_organization}/projects?page[size]=100"
  request_headers = {
    Authorization = "Bearer ${var.tfc_token}"
  }
}

data "http" "variable_sets" {
  url             = "https://app.terraform.io/api/v2/organizations/${var.tfc_organization}/varsets?page[size]=100"
  request_headers = {
    Authorization = "Bearer ${var.tfc_token}"
  }
}

locals {
  exclude_tags_query = var.tfc_workspace_exclude_tags != null  ? "&search[exclude-tags]=${join(",", var.tfc_workspace_exclude_tags)}" : ""
  include_tags_query = var.tfc_workspace_include_tags != null ? "&search[tags]=${join(",", var.tfc_workspace_include_tags)}" : ""

  workspaces_query = "https://app.terraform.io/api/v2/organizations/${var.tfc_organization}/workspaces?page[size]=100${local.exclude_tags_query}${local.include_tags_query}"
}

data "external" "workspaces" {
  program = ["node", "${path.module}/fetch_workspaces.js", local.workspaces_query, var.tfc_token]
}

data "tfe_variable_set" "all" {
  for_each = toset(local.variable_sets_ids)

  name         = local.variable_set_ids_to_names[each.key]
  organization = var.tfc_organization
}

data "tfe_variables" "all_sets_variables" {
  for_each = toset(local.variable_sets_ids)

  variable_set_id = each.key
}

data "http" "modules" {
  url             = "https://app.terraform.io/api/v2/organizations/${var.tfc_organization}/registry-modules?page[size]=100"
  request_headers = {
    Authorization = "Bearer ${var.tfc_token}"
  }
}

data "tfe_variables" "all" {
  for_each = toset(local.workspaces_ids)

  workspace_id = each.key
}
