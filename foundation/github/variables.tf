variable "owner" {
  description = "The GitHub account or organisation that owns the repository"
  type        = string
  default     = "jakubigla"
}

variable "repository" {
  description = "Repository name, without the owner"
  type        = string
  default     = "personal-site"
}

variable "visibility" {
  description = "public or private"
  type        = string
  default     = "public"
}

# Written by the foundation tooling; solo mode needs no team access to manage.
# tflint-ignore: terraform_unused_declarations
variable "owner_is_org" {
  description = "True when the owner is an organisation"
  type        = bool
  default     = false
}

# Written by the foundation tooling; solo mode needs no team access to manage.
# tflint-ignore: terraform_unused_declarations
variable "mode" {
  description = "solo (one maintainer) or team"
  type        = string
  default     = "solo"
}

variable "required_approvals" {
  description = "Approving reviews the ruleset requires; 0 for a solo maintainer"
  type        = number
  default     = 0
}

# Written by the foundation tooling; solo mode needs no team access to manage.
# tflint-ignore: terraform_unused_declarations
variable "maintainer_login" {
  description = "The maintainer's GitHub login"
  type        = string
  default     = "jakubigla"
}

variable "rulesets_enforced" {
  description = "False keeps the ruleset in evaluate mode, for plans that must not block anyone"
  type        = bool
  default     = true
}

variable "secret_scanning_available" {
  description = "Secret scanning settings exist on this plan and visibility"
  type        = bool
  default     = true
}

# Written by the foundation tooling for the deployment environments, which this stack does not manage yet.
# tflint-ignore: terraform_unused_declarations
variable "environment_protection_available" {
  description = "Deployment environment protection rules exist on this plan"
  type        = bool
  default     = true
}

# Written by the foundation tooling for the deployment environments, which this stack does not manage yet.
# tflint-ignore: terraform_unused_declarations
variable "environment_reviewers_available" {
  description = "Required reviewers on deployment environments exist on this plan"
  type        = bool
  default     = true
}

variable "adopt" {
  description = "Live settings that override the module's defaults, so the first plan reproduces them exactly"
  type        = any
  default     = {}
}
