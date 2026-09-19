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
