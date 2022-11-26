# Public ALB Security Group
resource "aws_security_group" "public_lb" {
  name_prefix = "${local.project_tag}-public-lb"
  description = "security group for public load balancer"
  vpc_id = aws_vpc.main.id
}

resource "aws_security_group_rule" "public_lb_allow_80" {
  security_group_id = aws_security_group.public_lb.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  description       = "Allow HTTP traffic."
}

resource "aws_security_group_rule" "public_lb_allow_outbound" {
  security_group_id = aws_security_group.public_lb.id
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  description       = "Allow any outbound traffic."
}

## Public Server Security Group
resource "aws_security_group" "public" {
  name_prefix = "${local.project_tag}-public"
  description = "Security Group for the public servers"
  vpc_id      = aws_vpc.main.id
}

resource "aws_security_group_rule" "public_allow_22" {
  security_group_id = aws_security_group.public.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow SSH traffic."
}

resource "aws_security_group_rule" "public_lb_allow_9090" {
  security_group_id = aws_security_group.public.id
  type = "ingress"
  protocol = "tcp"
  from_port = 9090
  to_port = 9090
  source_security_group_id = aws_security_group.public_lb.id
  description = "Allow traffic from Public Load Balancer."
}

resource "aws_security_group_rule" "public_allow_outbound" {
  security_group_id = aws_security_group.public.id
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  description       = "Allow any outbound traffic."
}

# Private ALB Security Group
resource "aws_security_group" "private_lb" {
  name_prefix = "${local.project_tag}-private-lb"
  description = "security group for private load balancer"
  vpc_id = aws_vpc.main.id
}

resource "aws_security_group_rule" "private_lb_allow_80" {
  security_group_id = aws_security_group.private_lb.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_blocks       = [var.vpc_cidr] # restrict to our VPC
  description       = "Allow HTTP traffic."
}

resource "aws_security_group_rule" "private_lb_allow_outbound" {
  security_group_id = aws_security_group.private_lb.id
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  description       = "Allow any outbound traffic."
}

## Private Server Security Group
resource "aws_security_group" "private" {
  name_prefix = "${local.project_tag}-private"
  description = "Security Group for the private servers"
  vpc_id      = aws_vpc.main.id
}

resource "aws_security_group_rule" "private_lb_allow_9090" {
  security_group_id = aws_security_group.private.id
  type = "ingress"
  protocol = "tcp"
  from_port = 9090
  to_port = 9090
  source_security_group_id = aws_security_group.private_lb.id
  description = "Allow traffic from Private Load Balancer."
}

resource "aws_security_group_rule" "private_allow_outbound" {
  security_group_id = aws_security_group.private.id
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow any outbound traffic."
}