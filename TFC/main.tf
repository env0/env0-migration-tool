resource "local_file" "data" {
  content  = jsonencode({ "workspaces" : local.final_workspace_list })
  filename = "${path.module}/out/data.json"
}
