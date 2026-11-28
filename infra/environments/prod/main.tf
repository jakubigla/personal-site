terraform {
  required_version = ">= 1.10"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.74"
    }
  }

  # Created by infra/bootstrap; S3 native locking, no lock table (ADR-0009).
  backend "s3" {
    bucket       = "jacops-pl-terraform-state"
    key          = "prod/terraform.tfstate"
    region       = "eu-central-1"
    encrypt      = true
    use_lockfile = true
  }
}

variable "serve_domain" {
  description = "False only for the first apply, before the aliases move (docs/runbooks/hosting-first-apply.md)"
  type        = bool
  default     = true
}

variable "contact_email" {
  description = "The public contact address the page publishes"
  type        = string
  default     = "jakub.igla@gmail.com"
}

provider "aws" {
  region = "eu-central-1"
}

# CloudFront only accepts certificates issued in us-east-1.
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

module "site_hosting" {
  source = "../../modules/site-hosting"
  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }

  domain       = "jacops.pl"
  bucket_name  = "jacops-pl-site"
  serve_domain = var.serve_domain
}

module "cost_guard" {
  source = "../../modules/cost-guard"

  email = var.contact_email
}

module "deploy_role" {
  source = "../../modules/deploy-role"

  github_repository = "jakubigla/personal-site"
  bucket_arn        = module.site_hosting.bucket_arn
  distribution_arn  = module.site_hosting.distribution_arn
}

output "deploy_role_arn" {
  value = module.deploy_role.role_arn
}

output "site_bucket" {
  value = module.site_hosting.bucket_name
}

output "distribution_id" {
  value = module.site_hosting.distribution_id
}

output "distribution_domain" {
  value = module.site_hosting.distribution_domain
}
