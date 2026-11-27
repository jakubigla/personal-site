resource "aws_wafv2_web_acl" "site" {
  name  = "fixture"
  scope = "CLOUDFRONT"

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "fixture"
    sampled_requests_enabled   = false
  }
}
