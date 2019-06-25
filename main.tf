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

data "aws_region" "region" {}

data "aws_vpc" "vpc" {
  id = "${var.vpc_id}"
}

resource "aws_security_group" "vpc" {
  name = "vpce-interface-${data.aws_vpc.vpc.id}"
  vpc_id = "${data.aws_vpc.vpc.id}"
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["${data.aws_vpc.vpc.cidr_block}"]
  }
  tags = {
    Name = "vpce"
  }
}

module "ssm" {
  source = "./vpce_interface"
  vpc_id = "${data.aws_vpc.vpc.id}"
  service = "ssm"
  security_group_ids = ["${aws_security_group.vpc.id}"]
}

module "ec2messages" {
  source = "./vpce_interface"
  vpc_id = "${data.aws_vpc.vpc.id}"
  service = "ec2messages"
  security_group_ids = ["${aws_security_group.vpc.id}"]
}

module "ec2" {
  source = "./vpce_interface"
  vpc_id = "${data.aws_vpc.vpc.id}"
  service = "ec2"
  security_group_ids = ["${aws_security_group.vpc.id}"]
}

module "ssmmessages" {
  source = "./vpce_interface"
  vpc_id = "${data.aws_vpc.vpc.id}"
  service = "ssmmessages"
  security_group_ids = ["${aws_security_group.vpc.id}"]
}

module "s3" {
  source = "./vpce_gateway"
  vpc_id = "${data.aws_vpc.vpc.id}"
  service = "s3"
  subnet_ids = ["${var.s3_subnet_ids}"]
}

