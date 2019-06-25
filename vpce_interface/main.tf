variable "vpc_id" {}

variable "service" {}

variable "security_group_ids" {
  type = "list"
}

data "aws_region" "region" {}

data "aws_vpc" "vpc" {
  id = "${var.vpc_id}"
}

data "aws_vpc_endpoint_service" "interface" {
  service_name = "com.amazonaws.${data.aws_region.region.name}.${var.service}"
}

locals {
  availability_zones = "${data.aws_vpc_endpoint_service.interface.availability_zones}"
}

data "aws_subnet_ids" "interface" {
  count = "${length(local.availability_zones)}"
  vpc_id = "${data.aws_vpc.vpc.id}"
  filter {
    name = "availability-zone"
    values = ["${local.availability_zones[count.index]}"]
  }
}

resource "random_shuffle" "subnet" {
  count = "${length(local.availability_zones)}"
  input = ["${data.aws_subnet_ids.interface.*.ids[count.index]}"]
  result_count = 1
}

resource "aws_vpc_endpoint" "interface" {
  vpc_id = "${data.aws_vpc.vpc.id}"
  service_name = "com.amazonaws.${data.aws_region.region.name}.${var.service}"
  vpc_endpoint_type = "Interface"
  subnet_ids = ["${flatten(random_shuffle.subnet.*.result)}"]
  security_group_ids = ["${var.security_group_ids}"]
  private_dns_enabled = true
  tags = {
    Name = "${var.service}"
  }
}

