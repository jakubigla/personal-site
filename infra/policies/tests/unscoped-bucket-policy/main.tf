resource "aws_s3_bucket" "site" {
  bucket = "fixture-site"
}

# The CloudFront service principal without an AWS:SourceArn condition: any distribution in any
# account could read the bucket.
resource "aws_s3_bucket_policy" "site" {
  bucket = aws_s3_bucket.site.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "cloudfront.amazonaws.com" }
      Action    = "s3:GetObject"
      Resource  = "${aws_s3_bucket.site.arn}/*"
    }]
  })
}
