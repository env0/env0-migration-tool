variable "workspaces" {
  description = "The list of workspaces exported. Should be set like this, for example: -var-file=../TFC/out/data.json"
}

variable "env0_org_id" {
  description = "The env0 organization ID"
}

variable "tfc_org_name" {
  description = "The name of the TFC organization"
}

variable "env0_hostname" {
  description = "The env0 hostname for the remote backend"
  default     = "backend.api.env0.com"
}
