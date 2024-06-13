resource "local_file" "data" {
  content  = jsonencode({ "workspaces" : local.final_workspace_list, "modules" : local.tfe_modules, "variable_sets" : local.all_variable_sets})
  filename = "${path.module}/out/data.json"
}
