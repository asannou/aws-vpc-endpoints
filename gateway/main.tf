variable "vpc_id" {
  type = string
}

variable "service" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

data "aws_region" "region" {
}

data "aws_route_tables" "gateway" {
  filter {
    name   = "association.subnet-id"
    values = var.subnet_ids
  }
}

resource "aws_vpc_endpoint" "gateway" {
  vpc_id          = var.vpc_id
  service_name    = "com.amazonaws.${data.aws_region.region.name}.${var.service}"
  route_table_ids = data.aws_route_tables.gateway.ids
  tags = {
    Name = var.service
  }
}

