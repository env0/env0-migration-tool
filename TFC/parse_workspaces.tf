locals {
  workspaces_ids  = [for _, id in data.tfe_workspace_ids.all.ids : id]
  workspace_names = [for name, _ in data.tfe_workspace_ids.all.ids : name]
  all_workspaces      = [
    for name, id in data.tfe_workspace_ids.all.ids : {
      env_vars = [
        for i, env_var in data.tfe_variables.all[id].variables : {
          hcl       = env_var.hcl
          name      = env_var.name
          sensitive = env_var.sensitive
          value     = env_var.value
          type      = env_var.category == "terraform" ? "terraform" : "environment"
        }
      ]
      labels            = data.tfe_workspace.all[name].tag_names
      name              = data.tfe_workspace.all[name].name
      description       = data.tfe_workspace.all[name].description
      terraform_version = data.tfe_workspace.all[name].terraform_version
      project_name      = local.project_ids_to_names[data.tfe_workspace.all[name].project_id]
      vcs               = {
        # The "identifier" argument contains the account/organization and the repository names, separated by a slash
        account = length(data.tfe_workspace.all[name].vcs_repo) > 0 ? split("/", data.tfe_workspace.all[name].vcs_repo[0].identifier)[0] : ""

        # When the branch for the stack is the repository's default branch, the value is empty so we use the value provided via the variable
        branch = length(data.tfe_workspace.all[name].vcs_repo) > 0 ? data.tfe_workspace.all[name].vcs_repo[0].branch != "" ? data.tfe_workspace.all[name].vcs_repo[0].branch : "" : ""

        project_root = data.tfe_workspace.all[name].working_directory

        # The "identifier" argument contains the account/organization and the repository names, separated by a slash
        repository = length(data.tfe_workspace.all[name].vcs_repo) > 0 ? split("/", data.tfe_workspace.all[name].vcs_repo[0].identifier)[1] : ""
      }
    }
  ]

  workspaces_with_vcs_repositories = [
    for workspace in local.all_workspaces : workspace if workspace.vcs.repository != ""
  ]
}
