# Base requirements for "hooking" Terraform up to AWS
# Analogy wise, this file represents the "Landmass"
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.15.1"
    }
  }
}

provider "aws" {
  region = var.aws_default_region
  default_tags {
    tags = var.aws_default_tags
  }
}