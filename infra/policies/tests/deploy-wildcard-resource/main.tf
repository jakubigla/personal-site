# Every bucket in the account instead of the site bucket.
resource "aws_iam_role_policy" "deploy" {
  name = "fixture-deploy"
  role = "fixture-deploy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "s3:PutObject"
      Resource = "*"
    }]
  })
}
