variable "aws_region" {
  type = string
}

variable "vpc_id" {
  type = string
}

provider "aws" {
  region = var.aws_region
}

module "common" {
  source = "github.com/asannou/terraform-aws-vpce//common?ref=0.12"
  vpc_id = var.vpc_id
}

module "sts" {
  source             = "github.com/asannou/terraform-aws-vpce//interface?ref=0.12"
  vpc_id             = var.vpc_id
  subnet_ids         = module.common.subnet_ids
  service            = "sts"
  security_group_ids = [module.common.security_group_id]
}

