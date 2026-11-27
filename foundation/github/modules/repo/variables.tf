variable "repository" {
  type = string
}

variable "visibility" {
  type = string
}

variable "required_approvals" {
  type = number
}

variable "rulesets_enforced" {
  type = bool
}

variable "secret_scanning_available" {
  type = bool
}

variable "adopt" {
  description = "Live settings that override the defaults below"
  type        = any
  default     = {}
}
