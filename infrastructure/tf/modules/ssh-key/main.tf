resource "tls_private_key" "kopsSsh" {
  algorithm = "RSA"
}

resource "aws_key_pair" "keyPair" {
  key_name   = "variantspark"
  public_key = "${tls_private_key.kopsSsh.public_key_openssh}"
}
