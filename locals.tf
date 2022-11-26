# Convenience locals for usage throughout the project
locals {
  project_tag = var.aws_default_tags.Project
  public_cidr_blocks = [for i in range(var.vpc_public_subnet_count) : cidrsubnet(var.vpc_cidr, 4, i)]
  private_cidr_blocks = [for i in range(var.vpc_private_subnet_count) : cidrsubnet(var.vpc_cidr, 4, i+var.vpc_public_subnet_count)]
}