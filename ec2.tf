# Datasource for grabbing the latest Ubuntu 18.04 AMI
data "aws_ssm_parameter" "ubuntu_1804_ami_id" {
  name = "/aws/service/canonical/ubuntu/server/18.04/stable/current/amd64/hvm/ebs-gp2/ami-id"
}

# Server - Buildings
resource "aws_instance" "server" {
  # count = 3 # Use the count meta-argument to make many
  ami                         = data.aws_ssm_parameter.ubuntu_1804_ami_id.value
  instance_type               = "t3.micro"
  vpc_security_group_ids      = [aws_security_group.public.id]
  subnet_id                   = aws_subnet.public[0].id
  associate_public_ip_address = true
  key_name                    = var.ec2_key_pair_name

  tags = { "Name" = "${local.project_tag}-server" }

  user_data = base64encode(templatefile("${path.module}/files/server.sh", {
    SERVICE_NAME = "service"
  }))
}
