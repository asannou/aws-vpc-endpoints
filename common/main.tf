variable "vpc_id" {
  type = "string"
}

data "aws_availability_zones" "az" {
  state = "available"
}

data "aws_vpc" "vpc" {
  id = "${var.vpc_id}"
}

data "external" "subnet" {
  program = ["/bin/bash", "${path.module}/calc_subnet_cidr.sh"]
  query = {
    vpc_cidr = "${data.aws_vpc.vpc.cidr_block}"
  }
}

resource "aws_subnet" "vpce" {
  count = "${length(data.aws_availability_zones.az.names)}"
  vpc_id = "${data.aws_vpc.vpc.id}"
  availability_zone = "${data.aws_availability_zones.az.names[count.index]}"
  cidr_block = "${cidrsubnet(data.external.subnet.result.subnet_cidr, 3, 7 - count.index)}"
  tags = {
    Name = "vpce-${data.aws_availability_zones.az.names[count.index]}"
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
  value = ["${aws_subnet.vpce.*.id}"]
}

output "security_group_id" {
  value = "${aws_security_group.vpce.id}"
}

