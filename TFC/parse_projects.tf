locals {
  projects_url_response    = jsondecode(data.http.projects.response_body)["data"]
  projects_response_as_map = tomap({
    for project in local.projects_url_response : project["id"] => project["attributes"]["name"]
  })
  project_ids          = toset([for workspace in data.tfe_workspace.all : workspace.project_id])
  project_ids_to_names = {
    for id in local.project_ids : id =>
    contains(keys(local.projects_response_as_map), id) ? local.projects_response_as_map[id] : id
  }

}
