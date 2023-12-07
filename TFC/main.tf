locals {
  data = jsonencode({
    "workspaces" : local.workspaces,
    "project_ids_to_names" : local.project_ids_to_names
  })
}

resource "local_file" "data" {
  content  = local.data
  filename = "${path.module}/out/data.json"
}
