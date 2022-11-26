# Public EC2 Launch Template - Blueprints for Buildings
resource "aws_launch_template" "public" {
  name_prefix = "${local.project_tag}-public-"
  image_id = data.aws_ssm_parameter.ubuntu_1804_ami_id.value
  instance_type = "t3.micro"
  key_name = var.ec2_key_pair_name
  vpc_security_group_ids = [aws_security_group.public.id]

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      { "Name" = "${local.project_tag}-public" },
      { "Project" = local.project_tag }
    )
  }

  tag_specifications {
    resource_type = "volume"
    
    tags = merge(
      { "Name" = "${local.project_tag}-public" },
      { "Project" = local.project_tag }
    )
  }

  tags = merge(
    { "Name" = "${local.project_tag}-public" },
    { "Project" = local.project_tag }
  )

  user_data = base64encode(templatefile("${path.module}/files/public.sh", {
    SERVICE_NAME = "public"
    PRIVATE_LB_URI = aws_lb.private.dns_name
  }))
}

# Public EC2 Auto Scaling Group - Foreman that takes the Blueprints (Launch template) and 
# makes many buildings based on desired_capacity, min_size, max_size
resource "aws_autoscaling_group" "public" {
  name_prefix = "${local.project_tag}-public-"

  launch_template {
    id = aws_launch_template.public.id
    version = aws_launch_template.public.latest_version
  }

  target_group_arns = [aws_lb_target_group.public.arn]

  # All the same to keep at a fixed size
  desired_capacity = 2
  min_size = 2
  max_size = 2

  # AKA the subnets to launch resources in 
  vpc_zone_identifier = aws_subnet.public.*.id

  health_check_grace_period = 300
  health_check_type = "EC2"
  termination_policies = ["OldestLaunchTemplate"]
  wait_for_capacity_timeout = 0

  enabled_metrics = [
    "GroupDesiredCapacity",
    "GroupInServiceCapacity",
    "GroupPendingCapacity",
    "GroupMinSize",
    "GroupMaxSize",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupStandbyCapacity",
    "GroupTerminatingCapacity",
    "GroupTerminatingInstances",
    "GroupTotalCapacity",
    "GroupTotalInstances"
  ]

  tags = [
    {
      key = "Name"
      value = "${local.project_tag}-public"
      propagate_at_launch = true
    },
    {
      key = "Project"
      value = local.project_tag
      propagate_at_launch = true
    }
  ]
}

# Private EC2 Launch Template - Blueprint
resource "aws_launch_template" "private" {
  name_prefix = "${local.project_tag}-private-"
  image_id = data.aws_ssm_parameter.ubuntu_1804_ami_id.value
  instance_type = "t3.micro"
  key_name = var.ec2_key_pair_name
  vpc_security_group_ids = [aws_security_group.private.id]

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      { "Name" = "${local.project_tag}-private" },
      { "Project" = local.project_tag }
    )
  }

  tag_specifications {
    resource_type = "volume"
    
    tags = merge(
      { "Name" = "${local.project_tag}-private" },
      { "Project" = local.project_tag }
    )
  }

  tags = merge(
    { "Name" = "${local.project_tag}-private" },
    { "Project" = local.project_tag }
  )

  user_data = base64encode(templatefile("${path.module}/files/private.sh", {
    SERVICE_NAME = "private"
  }))
}

# Private EC2 Auto Scaling Group - Foreman that uses the Blueprints to make many buildings
resource "aws_autoscaling_group" "private" {
  name_prefix = "${local.project_tag}-private-"

  launch_template {
    id = aws_launch_template.private.id
    version = aws_launch_template.private.latest_version
  }

  target_group_arns = [aws_lb_target_group.private.arn]

  # All the same to keep at a fixed size
  desired_capacity = 2
  min_size = 2
  max_size = 2

  # AKA the subnets to launch resources in 
  vpc_zone_identifier = aws_subnet.private.*.id

  health_check_grace_period = 300
  health_check_type = "EC2"
  termination_policies = ["OldestLaunchTemplate"]
  wait_for_capacity_timeout = 0

  enabled_metrics = [
    "GroupDesiredCapacity",
    "GroupInServiceCapacity",
    "GroupPendingCapacity",
    "GroupMinSize",
    "GroupMaxSize",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupStandbyCapacity",
    "GroupTerminatingCapacity",
    "GroupTerminatingInstances",
    "GroupTotalCapacity",
    "GroupTotalInstances"
  ]

  tags = [
    {
      key = "Name"
      value = "${local.project_tag}-private"
      propagate_at_launch = true
    },
    {
      key = "Project"
      value = local.project_tag
      propagate_at_launch = true
    }
  ]
}