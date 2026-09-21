output "api_endpoint" {
  value       = aws_apigatewayv2_stage.default.invoke_url
  description = "API Gateway endpoint URL"
}

output "api_id" {
  value       = aws_apigatewayv2_api.main.id
  description = "API Gateway ID"
}

output "api_name" {
  value       = aws_apigatewayv2_api.main.name
  description = "API Gateway name"
}

output "api_lambda_endpoints" {
  value = {
    for name, config in var.lambda_functions :
    name => "${aws_apigatewayv2_stage.default.invoke_url}${config.route}"
  }
  description = "Direct API Gateway endpoints for each Lambda function"
}
