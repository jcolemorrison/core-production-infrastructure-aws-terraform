## Public Application Load Balancer - Information Booth that directs traffic to buildings with enough capacity
resource "aws_lb" "public" {
  // Can't give it a full name_prefix due to 32 character limit on LBs
  // and the fact that Terraform adds a 26 character random bit to the end.
  // https://github.com/terraform-providers/terraform-provider-aws/issues/1666
  name_prefix = "pb-"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.public_lb.id]
  subnets = aws_subnet.public.*.id
  idle_timeout = 60
  ip_address_type = "dualstack"

  tags = merge(
    { "Name" = "${local.project_tag}-public"},
    { "Project" = local.project_tag }
  )
}

## Public Target Group
resource "aws_lb_target_group" "public" {
  name_prefix = "pb-"
  port = 9090
  protocol = "HTTP"
  vpc_id = aws_vpc.main.id
  deregistration_delay = 30
  target_type = "instance"

  health_check {
    enabled = true
    interval = 10
    path = "/"
    protocol = "HTTP"
    timeout = 5
    healthy_threshold = 3
    unhealthy_threshold = 3
    matcher = "200"
  }

  tags = merge(
    { "Name" = "${local.project_tag}-public"},
    { "Project" = local.project_tag }
  )
}

## Public Load Balancer Listener
resource "aws_lb_listener" "public_http_redirect" {
  load_balancer_arn = aws_lb.public.arn
  port = 80
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.public.arn
  }
}

## Private Application Load Balancer
resource "aws_lb" "private" {
  name_prefix = "pr-"
  internal = true # Makes it private
  load_balancer_type = "application"
  security_groups = [aws_security_group.private_lb.id]
  subnets = aws_subnet.private.*.id
  idle_timeout = 60

  tags = merge(
    { "Name" = "${local.project_tag}-private"},
    { "Project" = local.project_tag }
  )
}

## Private Target Group
resource "aws_lb_target_group" "private" {
  name_prefix = "pr-"
  port = 9090
  protocol = "HTTP"
  vpc_id = aws_vpc.main.id
  deregistration_delay = 30
  target_type = "instance"

  health_check {
    enabled = true
    interval = 10
    path = "/"
    protocol = "HTTP"
    timeout = 5
    healthy_threshold = 3
    unhealthy_threshold = 3
    matcher = "200"
  }

  tags = merge(
    { "Name" = "${local.project_tag}-private"},
    { "Project" = local.project_tag }
  )
}

## Private Load Balancer Listener
resource "aws_lb_listener" "private_http_redirect" {
  load_balancer_arn = aws_lb.private.arn
  port = 80
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.private.arn
  }
}