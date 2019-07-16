variable "vpc_id" {
  type = "string"
}

variable "subnet_ids" {
  type = "map"
}

variable "service" {
  type = "string"
}

variable "security_group_ids" {
  type = "list"
}

data "aws_region" "region" {}

data "aws_vpc_endpoint_service" "interface" {
  service_name = "com.amazonaws.${data.aws_region.region.name}.${var.service}"
}

locals {
  availability_zones = "${data.aws_vpc_endpoint_service.interface.availability_zones}"
  subnet_ids = "${matchkeys(values(var.subnet_ids), keys(var.subnet_ids), local.availability_zones)}"
}

resource "aws_vpc_endpoint" "interface" {
  vpc_id = "${var.vpc_id}"
  service_name = "com.amazonaws.${data.aws_region.region.name}.${var.service}"
  vpc_endpoint_type = "Interface"
  subnet_ids = ["${local.subnet_ids}"]
  security_group_ids = ["${var.security_group_ids}"]
  private_dns_enabled = true
  tags = {
    Name = "${var.service}"
  }
}

