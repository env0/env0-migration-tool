variable "workspaces" {
  description = "The list of workspaces exported. Should be set like this, for example: -var-file=../TFC/out/data.json"
}

variable "ado_token_id" {
  description = "env0 token id of the ADO repos"
  default = ""
}
