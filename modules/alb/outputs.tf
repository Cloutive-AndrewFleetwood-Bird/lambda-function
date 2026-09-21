output "alb_dns_name" {
  value       = aws_lb.main.dns_name
  description = "ALB DNS name"
}

output "alb_arn" {
  value       = aws_lb.main.arn
  description = "ALB ARN"
}

output "alb_name" {
  value       = aws_lb.main.name
  description = "ALB name"
}

output "target_group_names" {
  value = {
    for name, tg in aws_lb_target_group.lambda :
    name => tg.name
  }
  description = "Target group names"
}
