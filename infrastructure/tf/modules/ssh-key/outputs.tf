output "public_key_openssh" {
  value = "${tls_private_key.kopsSsh.public_key_openssh}"
}

output "private_key" {
  value = "${tls_private_key.kopsSsh.private_key_pem}"
}

output "key_name" {
  value = "${aws_key_pair.keyPair.key_name}"
}
