variable "cluster_name" {
  type = "string"
}

variable "caller_profile" {
  type = "string"
}

variable "vpc_id" {
  type = "string"
}

variable "public_subnets" {
  type = "list"
}

variable "master_role_arn" {
  type = "string"
}

variable "master_security_group_id" {
  type = "string"
}

variable "worker_profile_name" {
  type = "string"
}

variable "worker_role_arn" {
  type = "string"
}

variable "worker_security_group_id" {
  type = "string"
}

variable "eks_key_name" {
  type = "string"
}

variable "spark_user_arn" {
  type = "string"
}
