output "alb_endpoint" {
  value       = aws_lb.main.dns_name
  description = "The ALB DNS name for accessing Lambda services"
}

output "character_counter_url" {
  value       = "http://${aws_lb.main.dns_name}/count"
  description = "Character Counter endpoint via ALB"
}

output "json_validator_url" {
  value       = "http://${aws_lb.main.dns_name}/validate"
  description = "JSON Validator endpoint via ALB"
}
