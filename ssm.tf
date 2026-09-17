resource "aws_ssm_parameter" "char_counter_url_param" {
  name        = "/cinfra/services/char-counter/url"
  description = "The Route53 WAF-protected URL for the Character Counter Lambda"
  type        = "String"
  value       = "https://${aws_route53_record.char_counter_alias.name}"
  overwrite   = true 
}

resource "aws_ssm_parameter" "json_validator_url_param" {
  name        = "/cinfra/services/json-validator/url"
  description = "The Route53 WAF-protected URL for the JSON Validator Lambda"
  type        = "String"
  value       = "https://${aws_route53_record.json_validator_alias.name}"
  overwrite   = true
}
