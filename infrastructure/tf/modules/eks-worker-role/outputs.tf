output "worker_profile_name" {
  value = "${aws_iam_instance_profile.demo-node.name}"
}

output "worker_role_arn" {
  value = "${aws_iam_role.demo-node.arn}"
}
