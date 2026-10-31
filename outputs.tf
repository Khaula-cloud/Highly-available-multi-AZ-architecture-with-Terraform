output "alb_dns_name" {
  description = "Open this URL in your browser"
  value       = "http://${aws_lb.main.dns_name}"
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "asg_name" {
  value = aws_autoscaling_group.app.name
}

output "rds_endpoint" {
  value = aws_db_instance.main.address
}

output "rds_multi_az" {
  value = aws_db_instance.main.multi_az
}

output "db_secret_arn" {
  value = aws_db_instance.main.master_user_secret[0].secret_arn
}
