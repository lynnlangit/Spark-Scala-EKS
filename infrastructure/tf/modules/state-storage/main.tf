resource "aws_s3_bucket" "stateStore" {
  bucket_prefix = "variant-spark-k-state-store"
  provider      = "aws.use1"                    // to create bucket in us-east-1 as indicated by tutorial

  versioning {
    enabled = "true"
  }

  server_side_encryption_configuration {
    "rule" {
      "apply_server_side_encryption_by_default" {
        sse_algorithm = "AES256"
      }
    }
  }
}
