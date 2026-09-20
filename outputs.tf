output "alb_endpoint" {
  value       = aws_lb.main.dns_name
  description = "The ALB DNS name for accessing Lambda services"
}

output "lambda_endpoints" {
  value = {
    for name, config in var.lambda_functions :
    name => "http://${aws_lb.main.dns_name}${config.route}"
  }
  description = "Endpoints for all deployed Lambda functions"
}

output "lambda_function_names" {
  value       = [for fn in aws_lambda_function.functions : fn.function_name]
  description = "Names of deployed Lambda functions"
}

output "api_gateway_endpoint" {
  value       = aws_apigatewayv2_stage.default.invoke_url
  description = "The API Gateway endpoint URL"
}

output "api_gateway_lambda_endpoints" {
  value = {
    for name, config in var.lambda_functions :
    name => "${aws_apigatewayv2_stage.default.invoke_url}${config.route}"
  }
  description = "Direct API Gateway endpoints for each Lambda function"
}