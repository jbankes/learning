terraform {
  backend "s3" {
    bucket         = "ec2-root-exp-terraform-states"
    key            = "terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "ec2-root-exp-terraform-locks"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_kms_key" "this" {
  description = "KMS key for encrypting root volumes on experiment instances"
}

resource "aws_kms_alias" "this" {
  name          = "alias/ebs_root_experiment"
  target_key_id = aws_kms_key.this.id
}

resource "aws_instance" "this" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  root_block_device {
    encrypted  = true
    kms_key_id = aws_kms_key.this.id
  }

  tags = {
    Name = "ebs_root_experiment_instance"
  }
}
