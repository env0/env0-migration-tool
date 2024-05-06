resource "local_file" "data" {
  content  = jsonencode({ "workspaces" : local.final_workspace_list, "modules" : local.tfe_modules})
  filename = "${path.module}/out/data.json"
}
