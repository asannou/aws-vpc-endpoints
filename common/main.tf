variable "vpc_id" {
  type = "string"
}

variable "cidr_block" {
  type = "string"
  default = ""
}

variable "availability_zones" {
  type = "list"
  default = []
}

data "aws_availability_zones" "az" {
  state = "available"
}

data "aws_vpc" "vpc" {
  id = "${var.vpc_id}"
}

locals {
  vpc_cidr_prefix_length = "${element(split("/", data.aws_vpc.vpc.cidr_block), 1)}"
  newbits = "${24 - local.vpc_cidr_prefix_length}"
  netnum = "${pow(2, 24 - local.vpc_cidr_prefix_length) - 2}"
  cidr_block = "${var.cidr_block != "" ? var.cidr_block : cidrsubnet(data.aws_vpc.vpc.cidr_block, local.newbits, local.netnum)}"
  availability_zones = "${split(",", length(var.availability_zones) > 0 ? join(",", var.availability_zones) : join(",", data.aws_availability_zones.az.names))}"
  count = "${length(local.availability_zones)}"
  sub_newbits = "${ceil(log(local.count, 2))}"
}

resource "aws_subnet" "vpce" {
  count = "${local.count}"
  vpc_id = "${data.aws_vpc.vpc.id}"
  availability_zone = "${local.availability_zones[count.index]}"
  cidr_block = "${cidrsubnet(local.cidr_block, local.sub_newbits, count.index)}"
  tags = {
    Name = "vpce-${local.availability_zones[count.index]}"
  }
}

resource "aws_security_group" "vpce" {
  name = "vpce-${data.aws_vpc.vpc.id}"
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

output "subnet_ids" {
  value = "${zipmap(local.availability_zones, aws_subnet.vpce.*.id)}"
}

output "security_group_id" {
  value = "${aws_security_group.vpce.id}"
}

