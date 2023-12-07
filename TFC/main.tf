resource "local_file" "data" {
  content  = jsonencode({ "workspaces" : local.workspaces })
  filename = "${path.module}/out/data.json"
}
