locals {
  workspaces_from_response = jsondecode(data.http.workspaces.response_body)["data"]
  filtered_workspaces_by_name = [
    for workspace in local.workspaces_from_response : workspace if contains(var.tfc_workspace_names, workspace["attributes"]["name"])
  ]

  ids_from_response = [for workspace in local.filtered_workspaces_by_name : workspace["id"]]
  names_from_response = [for workspace in local.filtered_workspaces_by_name : workspace["attributes"]["name"]]
  
  workspaces_ids  = [for _, id in data.tfe_workspace_ids.all.ids : id]
  workspace_names = [for name, _ in data.tfe_workspace_ids.all.ids : name]
  all_workspaces  = [
    for workspace in local.filtered_workspaces_by_name : {
      env_vars = [
        for i, env_var in data.tfe_variables.all[workspace["id"]].variables : {
          hcl       = env_var.hcl
          name      = env_var.name
          sensitive = env_var.sensitive
          value     = env_var.sensitive ? "secret_value_from_terraform_cloud" : env_var.value
          type      = env_var.category == "terraform" ? "terraform" : "environment"
        }
      ]
      labels            = workspace["attributes"]["tag-names"]
      name              = workspace["attributes"]["name"]
      description       = workspace["attributes"]["description"]
      terraform_version = trimprefix(workspace["attributes"]["terraform-version"], "~>")
      project_name      = local.project_ids_to_names[workspace["relationships"]["project"]["data"]["id"]]
      vcs               = lookup(workspace["attributes"], "vcs-repo", null) != null ? {

        account =  workspace["attributes"]["vcs-repo"]["identifier"]

        # When the branch for the stack is the repository's default branch, the value is empty so we use the value provided via the variable
        branch = workspace["attributes"]["vcs-repo"]["branch"]

        project_root = workspace["attributes"]["working-directory"]

        # The "identifier" argument contains the account/organization and the repository names, separated by a slash
        repository = workspace["attributes"]["vcs-repo"]["repository-http-url"] 
      } : null
      sets_names             = [
        for variable_set in local.all_variable_sets : variable_set.name if contains(variable_set.workspace_ids, workspace["id"])
      ]
    }
  ]


  opentofu_type_and_version = { type = "opentofu", version = "latest" }
  split_versions            = {
    for workspace in local.all_workspaces : workspace.name =>
    split(".", workspace.terraform_version)
  }

  environment_type = {
    for workspace in local.all_workspaces :
    workspace.name =>
    local.opentofu_type_and_version
  }

  final_workspace_list = [
    for workspace in local.all_workspaces :
    merge(workspace, {
      type              = local.environment_type[workspace.name].type
      terraform_version = local.environment_type[workspace.name].type == "terraform" ? workspace.terraform_version : null
      opentofu_version  = local.environment_type[workspace.name].type == "opentofu" ? "latest" : null
    })
  ]
}

output "ids" {
  value = local.ids_from_response
}

output "names" {
  value = local.names_from_response
}

output "workspaces" { 
  value = local.all_workspaces
}