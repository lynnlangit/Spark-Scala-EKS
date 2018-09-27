resource "aws_s3_bucket" "inputBucket" {
  bucket_prefix = "variant-spark-k-storage"

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

resource "aws_s3_bucket_object" "inputFile" {
  bucket       = "${aws_s3_bucket.inputBucket.id}"
  key          = "input/sample_linear_regression_data.txt"
  source       = "${path.module}/sample_linear_regression_data.txt"
  content_type = "text/plain"
}
