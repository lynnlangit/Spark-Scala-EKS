output "kops_state_store" {
  value = "${aws_s3_bucket.stateStore.id}"
}
