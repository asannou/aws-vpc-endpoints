variable "aws_region" {
  type = "string"
}

variable "vpc_id" {
  type = "string"
}

variable "s3_subnet_ids" {
  type = "list"
}

provider "aws" {
  region = "${var.aws_region}"
}

module "common" {
  source = "github.com/asannou/terraform-aws-vpce//common"
  vpc_id = "${var.vpc_id}"
}

module "ssm" {
  source = "github.com/asannou/terraform-aws-vpce//ssm"
  vpc_id = "${var.vpc_id}"
  subnet_ids = ["${module.common.subnet_ids}"]
  security_group_ids = ["${module.common.security_group_id}"]
}

module "ec2" {
  source = "github.com/asannou/terraform-aws-vpce//interface"
  vpc_id = "${var.vpc_id}"
  subnet_ids = ["${module.common.subnet_ids}"]
  service = "ec2"
  security_group_ids = ["${module.common.security_group_id}"]
}

module "s3" {
  source = "github.com/asannou/terraform-aws-vpce//gateway"
  vpc_id = "${var.vpc_id}"
  service = "s3"
  subnet_ids = ["${var.s3_subnet_ids}"]
}

