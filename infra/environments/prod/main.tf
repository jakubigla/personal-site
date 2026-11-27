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

  domain      = "jacops.pl"
  bucket_name = "jacops-pl-site"
}

module "cost_guard" {
  source = "../../modules/cost-guard"

  # The public contact address the page publishes.
  email = "jakub.igla@gmail.com"
}

output "site_bucket" {
  value = module.site_hosting.bucket_name
}

output "distribution_id" {
  value = module.site_hosting.distribution_id
}
