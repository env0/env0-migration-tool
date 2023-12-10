resource "local_file" "data" {
  content  = jsonencode({ "workspaces" : local.workspaces_with_vcs_repositories })
  filename = "${path.module}/out/data.json"
}
