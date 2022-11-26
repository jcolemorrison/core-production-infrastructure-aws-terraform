output "service_endpoint" {
  description = "The public ALB endpoint for the public application."
  value = aws_lb.public.dns_name
}