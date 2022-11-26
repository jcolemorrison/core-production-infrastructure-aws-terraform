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