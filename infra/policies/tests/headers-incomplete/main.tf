resource "aws_cloudfront_response_headers_policy" "security" {
  name = "fixture"

  security_headers_config {
    content_type_options {
      override = true
    }
  }
}
