terraform {
  backend "s3" {
    bucket         = "BUCKET-PREFIX-terraform-states"
    key            = "terraform.tfstate"
    dynamodb_table = "replacement-terraform-locks"
    encrypt        = true
    region         = "us-west-2"
  }
}

provider "aws" {
  region = var.region
}

module "vpc" {
  source  = "aws-ia/vpc/aws"
  version = ">= 4.2.0"

  name                                 = "${var.vpc_name}-vpc"
  cidr_block                           = var.cidr_block
  vpc_assign_generated_ipv6_cidr_block = true
  vpc_egress_only_internet_gateway     = true
  az_count                             = 3

  subnets = {
    public = {
      netmask                   = 20
      assign_ipv6_cidr          = true
      nat_gateway_configuration = "all_azs" # or "single_az"
    }
    # IPv4 only subnet
    private = {
      netmask                 = 24
      connect_to_public_natgw = true
    }
    # IPv6-only subnet
    private_ipv6 = {
      ipv6_native      = true
      assign_ipv6_cidr = true
      connect_to_eigw  = true
    }
  }

  vpc_flow_logs = {
    log_destination_type = "cloud-watch-logs"
    retention_in_days    = 180
  }
}
