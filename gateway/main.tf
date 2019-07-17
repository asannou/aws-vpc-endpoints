variable "vpc_id" {
  type = string
}

variable "service" {
  type = string
}

variable "route_table_ids" {
  type    = list(string)
  default = []
}

variable "subnet_ids" {
  type    = list(string)
  default = []
}

data "aws_region" "region" {
}

data "aws_route_tables" "gateway" {
  count = length(var.subnet_ids) == 0 ? 0 : 1
  filter {
    name   = "association.subnet-id"
    values = var.subnet_ids
  }
}

locals {
  subnet_route_table_ids = length(var.subnet_ids) == 0 ? [] : tolist(data.aws_route_tables.gateway[0].ids)
}

resource "aws_vpc_endpoint" "gateway" {
  vpc_id          = var.vpc_id
  service_name    = "com.amazonaws.${data.aws_region.region.name}.${var.service}"
  route_table_ids = concat(var.route_table_ids, local.subnet_route_table_ids)
  tags = {
    Name = var.service
  }
}

