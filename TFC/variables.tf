variable "tfc_organization" {
  description = "TFC/TFE organization name"
  type        = string
}

variable "tfc_workspace_names" {
  default     = ["*"]
  description = "List of TFC/TFE workspace names to export. Wildcards are supported (e.g., [\"*\"], [\"*-example\"], [\"example-*\"])."
  type        = list(string)
}

variable "tfc_workspace_exclude_tags" {
  default     = null
  description = "List of TFC/TFE workspace tags to exclude when exporting. Excluded tags take precedence over included ones. Wildcards are not supported."
  type        = list(string)
}

variable "tfc_workspace_include_tags" {
  default     = null
  description = "List of TFC/TFE workspace tags to include when exporting. Excluded tags take precedence over included ones. Wildcards are not supported."
  type        = list(string)
}

variable "tfc_token" {
  description = "TFC/TFE token"
  type        = string
}
