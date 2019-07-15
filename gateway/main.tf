variable "vpc_id" {
  type = "string"
}

variable "service" {
  type = "string"
}

variable "route_table_ids" {
  type = "list"
}

data "aws_region" "region" {}

resource "aws_vpc_endpoint" "gateway" {
  vpc_id = "${var.vpc_id}"
  service_name = "com.amazonaws.${data.aws_region.region.name}.${var.service}"
  route_table_ids = ["${var.route_table_ids}"]
  tags = {
    Name = "${var.service}"
  }
}

