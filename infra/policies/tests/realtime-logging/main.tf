resource "aws_cloudfront_realtime_log_config" "fixture" {
  name          = "fixture"
  sampling_rate = 100
  fields        = ["timestamp"]
  endpoint {
    stream_type = "Kinesis"
    kinesis_stream_config {
      role_arn   = "arn:aws:iam::000000000000:role/fixture"
      stream_arn = "arn:aws:kinesis:eu-central-1:000000000000:stream/fixture"
    }
  }
}
