terraform {
  required_version = ">= 1.10"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.74"
    }
  }
}

variable "email" {
  description = "Address that receives the budget notifications"
  type        = string
}

variable "limit_usd" {
  description = "Monthly cost cap in USD"
  type        = string
  default     = "2"
}

resource "aws_budgets_budget" "monthly" {
  name         = "site-monthly-cost"
  budget_type  = "COST"
  time_unit    = "MONTHLY"
  limit_amount = var.limit_usd
  limit_unit   = "USD"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.email]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.email]
  }
}
