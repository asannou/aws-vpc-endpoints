variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "service" {
  type = string
}

variable "security_group_ids" {
  type = list(string)
}

data "aws_region" "region" {
}

data "aws_vpc_endpoint_service" "interface" {
  service_name = "com.amazonaws.${data.aws_region.region.name}.${var.service}"
}

locals {
  availability_zones = tolist(data.aws_vpc_endpoint_service.interface.availability_zones)
}

data "aws_subnet_ids" "interface" {
  count  = length(local.availability_zones)
  vpc_id = var.vpc_id
  filter {
    name   = "subnet-id"
    values = var.subnet_ids
  }
  filter {
    name   = "availability-zone"
    values = [local.availability_zones[count.index]]
  }
}

resource "aws_vpc_endpoint" "interface" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${data.aws_region.region.name}.${var.service}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = flatten(data.aws_subnet_ids.interface.*.ids)
  security_group_ids  = var.security_group_ids
  private_dns_enabled = true
  tags = {
    Name = var.service
  }
}

