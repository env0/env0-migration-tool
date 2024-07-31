locals {
  workspaces_from_response = jsondecode(data.http.workspaces.response_body)["data"]
  filtered_workspaces_by_name = [
    for workspace in local.workspaces_from_response : workspace if contains(var.tfc_workspace_names, workspace["attributes"]["name"])
  ]

  all_workspaces  = [
    for workspace in local.filtered_workspaces_by_name : {
      id        = workspace["id"]
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

        is_gitlab         = can(regex("gitlab", workspace["attributes"]["vcs-repo"]["repository-http-url"] ))
        account           =  workspace["attributes"]["vcs-repo"]["identifier"]

          # When the branch for the stack is the repository's default branch, the value is empty so we use the value provided via the variable
          branch          = workspace["attributes"]["vcs-repo"]["branch"]

          project_root    = workspace["attributes"]["working-directory"]

          # The "identifier" argument contains the account/organization and the repository names, separated by a slash
          repository      = workspace["attributes"]["vcs-repo"]["repository-http-url"] 
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
    local.split_versions[workspace.name][0] == "latest" ? local.opentofu_type_and_version : parseint(local.split_versions[workspace.name][0], 10) > 1 ? local.opentofu_type_and_version :
    parseint(local.split_versions[workspace.name][0], 10) == 1 && parseint(local.split_versions[workspace.name][1], 10) >= 6 ? local.opentofu_type_and_version :
    { type = "terraform" }
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