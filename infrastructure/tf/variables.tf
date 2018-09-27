variable "default_region" {
  default = "us-west-2"
}

variable "project" {
  default = "kops1"
}

variable "profile" {
  default = "default"
}

variable "cluster-name" {
  default = "terraform-eks-demo"
  type    = "string"
}
