resource "aws_ssm_parameter" "alb_endpoint" {
  name        = "/cinfra/services/alb-endpoint"
  description = "The ALB endpoint for Lambda services"
  type        = "String"
  value       = aws_lb.main.dns_name
  overwrite   = true
}

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
