locals {
    modules_url_response    = jsondecode(data.http.modules.response_body)["data"]
    tfe_modules = [
        for module in local.modules_url_response : {
            module_name         = module.attributes.name
            repository          = module.attributes.vcs-repo.repository-http-url
            module_provider     = module.attributes.provider
        }
    ]
}