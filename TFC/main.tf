terraform {
  required_version = "~> 1.2"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2.1"
    }
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.45.0"
    }
  }
}

locals {
  workspaces_ids   = [for _, id in data.tfe_workspace_ids.all.ids : id]
  workspace_names = [for name, _ in data.tfe_workspace_ids.all.ids : name]
  workspaces = [for name, id in data.tfe_workspace_ids.all.ids : {
    env_vars = [for i, env_var in data.tfe_variables.all[id].variables : {
      hcl       = env_var.hcl
      name      = env_var.category == "terraform" ? "TF_VAR_${env_var.name}" : env_var.name
      sensitive = env_var.sensitive
      value     = env_var.value
    }]
    labels            = data.tfe_workspace.all[name].tag_names
    name              = data.tfe_workspace.all[name].name
    terraform_version = data.tfe_workspace.all[name].terraform_version
    vcs = {
      # The "identifier" argument contains the account/organization and the repository names, separated by a slash
      account = length(data.tfe_workspace.all[name].vcs_repo) > 0 ? split("/", data.tfe_workspace.all[name].vcs_repo[0].identifier)[0] : ""

      # When the branch for the stack is the repository's default branch, the value is empty so we use the value provided via the variable
      branch = length(data.tfe_workspace.all[name].vcs_repo) > 0 ? data.tfe_workspace.all[name].vcs_repo[0].branch != "" ? data.tfe_workspace.all[name].vcs_repo[0].branch : var.vcs_default_branch : var.vcs_default_branch

      namespace    = var.vcs_namespace
      project_root = data.tfe_workspace.all[name].working_directory

      # The "identifier" argument contains the account/organization and the repository names, separated by a slash
      repository = length(data.tfe_workspace.all[name].vcs_repo) > 0 ? split("/", data.tfe_workspace.all[name].vcs_repo[0].identifier)[1] : ""
    }
  }]
  project_ids = toset([for workspace in data.tfe_workspace.all : workspace.project_id])
  data = jsonencode({
    "workspaces" : local.workspaces,
    "project_ids"   : local.project_ids
  })
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

resource "local_file" "data" {
  content  = local.data
  filename = "${path.module}/out/data.json"
}
