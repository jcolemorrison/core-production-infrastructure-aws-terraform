# Main VPC resource - The City
resource "aws_vpc" "main" {
  cidr_block                       = var.vpc_cidr
  instance_tenancy                 = var.vpc_instance_tenancy
  enable_dns_support               = true
  enable_dns_hostnames             = true
  assign_generated_ipv6_cidr_block = true

  tags = { "Name" = "${local.project_tag}-vpc" }
}

# Subnets - Districts

## Public Subnets
resource "aws_subnet" "public" {
  count = var.vpc_public_subnet_count

  vpc_id = aws_vpc.main.id

  # create subnets based on the vpc's cidr_block and chosen count
  cidr_block              = local.public_cidr_blocks[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  # create ipv6 subnets based on the vpc's cidr_block and chosen count
  ipv6_cidr_block                 = cidrsubnet(aws_vpc.main.ipv6_cidr_block, 8, count.index)
  assign_ipv6_address_on_creation = true

  tags = { "Name" = "${local.project_tag}-public-${data.aws_availability_zones.available.names[count.index]}" }
}

## Private Subnets
resource "aws_subnet" "private" {
  count = var.vpc_private_subnet_count

  vpc_id = aws_vpc.main.id

  // Increment the netnum by the number of public subnets to avoid overlap
  cidr_block = local.private_cidr_blocks[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = { "Name" = "${local.project_tag}-private-${data.aws_availability_zones.available.names[count.index]}" }
}

# Route Tables and Routes - The "Roads"

## Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = { "Name" = "${local.project_tag}-public-rtb" }
}

### Public Subnet Route Associations - connect the public subnets with the route tables
resource "aws_route_table_association" "public" {
  count = var.vpc_public_subnet_count

  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

## Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = { "Name" = "${local.project_tag}-private-rtb" }
}

### Private Subnet Route Associations - connect the public subnets with the route tables
resource "aws_route_table_association" "private" {
  count = var.vpc_private_subnet_count

  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.private.id
}

# Internet Gateway - The Highway On-Ramp
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = { "Name" = "${local.project_tag}-igw" }
}

## Route to the Internet Gateway
resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# The NAT Elastic IP, required for the NAT Gateway
resource "aws_eip" "nat" {
  vpc = true

  tags = { "Name" = "${local.project_tag}-nat-eip" }

  depends_on = [aws_internet_gateway.igw]
}

# The NAT Gateway - The Connection to the Highway On-Ramp
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.0.id

  tags = { "Name" = "${local.project_tag}-nat" }

  depends_on = [
    aws_internet_gateway.igw,
    aws_eip.nat
  ]
}

## Route to the NAT Gateway
resource "aws_route" "private_internet_access" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

# Egress Only Gateway (IPv6) - IPV6 "equivalent" of the NAT Gateway
resource "aws_egress_only_internet_gateway" "eigw" {
  vpc_id = aws_vpc.main.id
}

## Route to the Egress Only Internet Gateway
resource "aws_route" "private_internet_access_ipv6" {
  route_table_id              = aws_route_table.private.id
  destination_ipv6_cidr_block = "::/0"
  egress_only_gateway_id      = aws_egress_only_internet_gateway.eigw.id
}

# NOTE: the default Network ACLs are used so there is no code for them here.
# Terraform Docs on NACLs: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_acl