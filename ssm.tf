resource "aws_ssm_parameter" "char_counter_url_param" {
  name        = "/cinfra/services/char-counter/url"
  description = "The URL for the Character Counter Lambda"
  type        = "String"
  value       = aws_lambda_function_url.char_counter_url.function_url
  overwrite   = true 
}

resource "aws_ssm_parameter" "json_validator_url_param" {
  name        = "/cinfra/services/json-validator/url"
  description = "The WAF-protected ALB URL for the JSON Validator Lambda"
  type        = "String"
  value       = aws_lambda_function_url.json_validator_url.function_url
  overwrite   = true
}

output "character_counter_url" {
  value       = aws_lambda_function_url.char_counter_url.function_url
  description = "The direct endpoint for the Character Counter"
}

output "json_validator_url" {
  value       = aws_lambda_function_url.json_validator_url.function_url
  description = "The direct endpoint for the JSON Validator"
}
