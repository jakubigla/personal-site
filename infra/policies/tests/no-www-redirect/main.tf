resource "aws_cloudfront_function" "router" {
  name    = "fixture"
  runtime = "cloudfront-js-2.0"
  publish = true
  code    = "function handler(event) { return event.request; }"
}
