terraform {
  backend "s3" {
    bucket  = "variant-spark-july"
    key     = "variantspark-k/tfstate"
    region  = "us-west-2"
    profile = "default"
  }
}

provider "aws" {
  profile = "${var.profile}"
  region  = "${var.default_region}"
}

provider "aws" {
  alias   = "use1"
  profile = "${var.profile}"
  region  = "us-east-1"
}

module "eks-vpc" {
  source         = "modules/eks-vpc"
  "cluster-name" = "${var.cluster-name}"
}

module "eks-master-role" {
  source = "modules/eks-master-role"
}

module "eks-master-security-group" {
  source = "modules/eks-master-security-group"
  vpc_id = "${module.eks-vpc.vpc_id}"
}

module "eks-worker-role" {
  source = "modules/eks-worker-role"
}

module "eks-worker-security-group" {
  source = "modules/eks-worker-security-group"

  vpc_id                   = "${module.eks-vpc.vpc_id}"
  master_security_group_id = "${module.eks-master-security-group.security_group_id}"
  "cluster-name"           = "${var.cluster-name}"
}

module "eks" {
  source                   = "modules/eks"
  cluster_name             = "${var.cluster-name}"
  vpc_id                   = "${module.eks-vpc.vpc_id}"
  public_subnets           = "${module.eks-vpc.public_subnets}"
  master_role_arn          = "${module.eks-master-role.master_role_arn}"
  master_security_group_id = "${module.eks-master-security-group.security_group_id}"
  worker_role_arn          = "${module.eks-worker-role.worker_role_arn}"
  worker_profile_name      = "${module.eks-worker-role.worker_profile_name}"
  worker_security_group_id = "${module.eks-worker-security-group.security_group_id}"
  caller_profile           = "${var.profile}"
  eks_key_name             = "${module.kops-ssh.key_name}"
  spark_user_arn           = "${module.kops-user.arn}"
}

module "kops-user" {
  source = "modules/kops-user"
}

module "state-storage" {
  source = "modules/state-storage"
}

module "input-bucket" {
  source = "modules/input-bucket"
}

module "kops-ssh" {
  source = "modules/ssh-key"
}

data "aws_availability_zones" "available" {}

data "template_file" "env" {
  template = "${file("templates/env.tpl")}"

  vars {
    aws_access_key_id     = "${module.kops-user.aws_access_key_id}"
    aws_secret_access_key = "${module.kops-user.aws_secret_access_key}"
    aws_availability_zone = "${data.aws_availability_zones.available.names[0]}"
    kops_state_store      = "${module.state-storage.kops_state_store}"
    input_bucket          = "${module.input-bucket.input_bucket}"
    project               = "${var.project}"
  }
}

resource "local_file" "env" {
  filename = "out/env"
  content  = "${data.template_file.env.rendered}"
}

resource "local_file" "sshPublicKey" {
  filename = "out/id_rsa.pub"
  content  = "${module.kops-ssh.public_key_openssh}"
}

resource "local_file" "sshPrivateKey" {
  filename = "out/id_rsa"
  content  = "${module.kops-ssh.private_key}"
}

resource "local_file" "kubeconfig" {
  filename = "out/config"
  content  = "${module.eks.kubeconfig}"
  provisioner "local-exec" {
    command = "cp out/config ~/.kube/config"
  }
}

resource "local_file" "config-map-aws-auth" {
  filename = "out/setup.yaml"
  content  = "${module.eks.config-map-aws-auth}"
}
