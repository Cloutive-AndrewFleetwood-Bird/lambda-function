resource "aws_ssm_parameter" "char_counter_url_param" {
  name        = "/cinfra/services/char-counter/url"
  description = "The WAF-protected ALB URL for the Character Counter Lambda"
  type        = "String"
  value       = "http://${aws_lb.main.dns_name}/count"
  overwrite   = true 
}

resource "aws_ssm_parameter" "json_validator_url_param" {
  name        = "/cinfra/services/json-validator/url"
  description = "The WAF-protected ALB URL for the JSON Validator Lambda"
  type        = "String"
  value       = "http://${aws_lb.main.dns_name}/validate"
  overwrite   = true
}

output "character_counter_url" {
  value       = "http://${aws_lb.main.dns_name}/count"
  description = "The direct endpoint for the Character Counter"
}

output "json_validator_url" {
  value       = "http://${aws_lb.main.dns_name}/validate"
  description = "The direct endpoint for the JSON Validator"
}
