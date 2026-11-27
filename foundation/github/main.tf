# GitHub repository settings as code. Only the owner plans and applies this stack, locally and
# attended (ADR-0010): no CI identity exists for it. The first plan imports the live settings and
# must change nothing on GitHub.
terraform {
  required_version = ">= 1.10"
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.13"
    }
  }

  # Partial: the platform's state bucket (ADR-0009) with this stack's own key, supplied as
  # backend.hcl at init, so the bucket name is written in one place only.
  backend "s3" {}
}

# The token comes from the owner's environment (GITHUB_TOKEN) and is never written to a file.
provider "github" {
  owner = var.owner
}

module "repo" {
  source = "./modules/repo"

  repository                = var.repository
  visibility                = var.visibility
  required_approvals        = var.required_approvals
  rulesets_enforced         = var.rulesets_enforced
  secret_scanning_available = var.secret_scanning_available
  adopt                     = var.adopt
}
