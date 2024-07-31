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

data "http" "workspaces" { 
  url             = "https://app.terraform.io/api/v2/organizations/${var.tfc_organization}/workspaces?page[size]=100&search[exclude-tags]=${join(",", var.tfc_workspace_exclude_tags)}&search[tags]=${join(",", var.tfc_workspace_include_tags)}"
  request_headers = {
    Authorization = "Bearer ${var.tfc_token}"
  }
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
