locals {
  variable_sets_url_response    = jsondecode(data.http.variable_sets.response_body)["data"]
  variable_sets_response_as_map = tomap({
    for variable_set in local.variable_sets_url_response : variable_set["id"] => variable_set["attributes"]["name"]
  })
  variable_sets_ids          = toset([for variable_set in local.variable_sets_url_response : variable_set["id"]])
  variable_set_ids_to_names = {
    for id in local.variable_sets_ids : id =>
    contains(keys(local.variable_sets_response_as_map), id) ? local.variable_sets_response_as_map[id] : id
  }
  all_variable_sets = [
    for name, id in data.tfe_variable_set.all : {

      name = name
      description = data.tfe_variable_set.all[name].description
      env_vars = [
        for i, env_var in data.tfe_variables.all_sets_variables[id].variables : {
          hcl       = env_var.hcl
          name      = env_var.name
          sensitive = env_var.sensitive
          value     = env_var.sensitive ? "secret_value_from_terraform_cloud" : env_var.value
          type      = env_var.category == "terraform" ? "terraform" : "environment"
        }
      ]

    }
  ]
}
