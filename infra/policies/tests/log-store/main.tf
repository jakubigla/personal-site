resource "aws_s3_bucket" "logs" {
  bucket = "fixture-logs"
}

resource "aws_s3_bucket_logging" "logs" {
  bucket        = aws_s3_bucket.logs.id
  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "log/"
}
