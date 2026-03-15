terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=6.19"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = ">=2.3"
    }
  }
}

provider "aws" {
  default_tags {
    tags = merge(
      {
        Terraform = "true",
        Env       = local.env_name
      },
      var.owner_name == null ? {} : { Owner = var.owner_name },
      var.tags
    )
  }
}

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_region" "current" {}

data "http" "myip" {
  count = var.allowed_ssh_cidr == null ? 1 : 0

  url = "https://ipv4.icanhazip.com"
}

locals {
  allowed_ssh_cidr     = var.allowed_ssh_cidr == null ? "${trim(data.http.myip[0].response_body, "\n")}/32" : var.allowed_ssh_cidr
  allowed_ingress_cidr = var.allowed_ingress_cidr == null ? local.allowed_ssh_cidr : var.allowed_ingress_cidr
  deploy_rke2          = var.deploy_rke2
  env_name             = var.env_name
  num_servers          = var.num_servers
  tag_name             = var.tag_name == null ? var.resource_name : var.tag_name

  aws_account_id = data.aws_caller_identity.current.account_id
  aws_partition  = data.aws_partition.current.partition
  aws_region     = var.aws_region == null ? data.aws_region.current.region : var.aws_region
}
