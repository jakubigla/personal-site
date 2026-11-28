# A wildcard action lets the role change the bucket's policy or delete it.
resource "aws_iam_role_policy" "deploy" {
  name = "fixture-deploy"
  role = "fixture-deploy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "s3:*"
      Resource = "arn:aws:s3:::fixture-site/*"
    }]
  })
}
