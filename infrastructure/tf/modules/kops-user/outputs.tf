output "aws_access_key_id" {
  value     = "${aws_iam_access_key.kopsAccessKey.id}"
  sensitive = true
}

output "aws_secret_access_key" {
  value     = "${aws_iam_access_key.kopsAccessKey.secret}"
  sensitive = true
}

output "arn" {
  value = "${aws_iam_user.kops.arn}"
}
