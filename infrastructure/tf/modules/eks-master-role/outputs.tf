output "master_role_arn" {
  value = "${aws_iam_role.demo-cluster.arn}"
}
