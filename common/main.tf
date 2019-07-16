variable "vpc_id" {
  type = string
}

variable "cidr_block" {
  type = string
  default = null
}

data "aws_availability_zones" "az" {
  state = "available"
}

data "aws_vpc" "vpc" {
  id = var.vpc_id
}

locals {
  vpc_cidr_prefix_length = split("/", data.aws_vpc.vpc.cidr_block)[1]
  newbits                = 24 - local.vpc_cidr_prefix_length
  netnum                 = pow(2, 24 - local.vpc_cidr_prefix_length) - 2
  cidr_block             = var.cidr_block != null ? var.cidr_block : cidrsubnet(data.aws_vpc.vpc.cidr_block, local.newbits, local.netnum)
}

resource "aws_subnet" "vpce" {
  count             = length(data.aws_availability_zones.az.names)
  vpc_id            = data.aws_vpc.vpc.id
  availability_zone = data.aws_availability_zones.az.names[count.index]
  cidr_block        = cidrsubnet(local.cidr_block, 3, 7 - count.index)
  tags = {
    Name = "vpce-${data.aws_availability_zones.az.names[count.index]}"
  }
}

resource "aws_security_group" "vpce" {
  name   = "vpce-${data.aws_vpc.vpc.id}"
  vpc_id = data.aws_vpc.vpc.id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [data.aws_vpc.vpc.cidr_block]
  }
  tags = {
    Name = "vpce"
  }
}

output "subnet_ids" {
  value = aws_subnet.vpce.*.id
}

output "security_group_id" {
  value = aws_security_group.vpce.id
}

