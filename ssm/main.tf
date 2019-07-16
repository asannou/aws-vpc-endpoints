variable "vpc_id" {
  type = "string"
}

variable "subnet_ids" {
  type = "map"
}

variable "security_group_ids" {
  type = "list"
}

module "ssm" {
  source = "../interface"
  vpc_id = "${var.vpc_id}"
  subnet_ids = "${var.subnet_ids}"
  service = "ssm"
  security_group_ids = ["${var.security_group_ids}"]
}

module "ec2messages" {
  source = "../interface"
  vpc_id = "${var.vpc_id}"
  subnet_ids = "${var.subnet_ids}"
  service = "ec2messages"
  security_group_ids = ["${var.security_group_ids}"]
}

module "ssmmessages" {
  source = "../interface"
  vpc_id = "${var.vpc_id}"
  subnet_ids = "${var.subnet_ids}"
  service = "ssmmessages"
  security_group_ids = ["${var.security_group_ids}"]
}

