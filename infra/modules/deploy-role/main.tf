terraform {
  required_version = ">= 1.10"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.74"
    }
  }
}

variable "github_repository" {
  description = "owner/name of the repository whose main branch may assume the role"
  type        = string
}

variable "role_name" {
  description = "Name of the one role CI assumes"
  type        = string
  default     = "site-deploy"
}

variable "bucket_arn" {
  description = "ARN of the site bucket the role may write"
  type        = string
}

variable "distribution_arn" {
  description = "ARN of the distribution the role may invalidate"
  type        = string
}

locals {
  issuer = "token.actions.githubusercontent.com"
}

# One provider per account and issuer. If the account already has one, import it before the
# first apply instead of creating a second (docs/runbooks/deploy-first-apply.md).
resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://${local.issuer}"
  client_id_list = ["sts.amazonaws.com"]
}

# The subject claim of a push to main is exactly this string. A pull request's is
# repo:<owner>/<name>:pull_request, a fork's names the fork, another branch's names its ref, so an
# exact match on it rejects them all; StringLike or a wildcard would not.
resource "aws_iam_role" "deploy" {
  name                 = var.role_name
  max_session_duration = 3600
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = aws_iam_openid_connect_provider.github.arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${local.issuer}:aud" = "sts.amazonaws.com"
          "${local.issuer}:sub" = "repo:${var.github_repository}:ref:refs/heads/main"
        }
      }
    }]
  })
}

# Writing objects and invalidating one distribution is all a deploy does. No delete: hashed
# assets are never removed (ADR-0011) and every changed file is overwritten in place.
resource "aws_iam_role_policy" "deploy" {
  name = "site-deploy"
  role = aws_iam_role.deploy.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "ListSiteBucket"
        Effect   = "Allow"
        Action   = "s3:ListBucket"
        Resource = var.bucket_arn
      },
      {
        Sid      = "WriteSiteObjects"
        Effect   = "Allow"
        Action   = "s3:PutObject"
        Resource = "${var.bucket_arn}/*"
      },
      {
        Sid      = "InvalidateSiteDistribution"
        Effect   = "Allow"
        Action   = ["cloudfront:CreateInvalidation", "cloudfront:GetInvalidation"]
        Resource = var.distribution_arn
      },
    ]
  })
}

output "role_arn" {
  description = "Value of the DEPLOY_ROLE_ARN repository variable"
  value       = aws_iam_role.deploy.arn
}
