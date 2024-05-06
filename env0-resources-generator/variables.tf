variable "workspaces" {
  description = "The list of exported tfe workspaces."
}

variable "modules" {
  description = "The list of exported tfe modules."
}

variable "include_vcs_connection" {
  description = "Include the VCS connection on the created environments"
  default     = false
}