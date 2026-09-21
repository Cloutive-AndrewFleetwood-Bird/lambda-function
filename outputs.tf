output "alb_endpoint" {
  value       = module.alb.alb_dns_name
  description = "The ALB DNS name for accessing Lambda services"
}

output "lambda_endpoints" {
  value = {
    for name, config in var.lambda_functions :
    name => "http://${module.alb.alb_dns_name}${config.route}"
  }
  description = "Endpoints for all deployed Lambda functions via ALB"
}

output "api_gateway_endpoint" {
  value       = module.api_gateway.api_endpoint
  description = "The API Gateway endpoint URL"
}

output "api_gateway_lambda_endpoints" {
  value       = module.api_gateway.api_lambda_endpoints
  description = "Direct API Gateway endpoints for each Lambda function"
}

output "lambda_function_names" {
  value       = module.lambda.all_function_names
  description = "Names of deployed Lambda functions"
}

output "vpc_id" {
  value       = module.networking.vpc_id
  description = "VPC ID"
}

output "public_subnet_ids" {
  value       = module.networking.public_subnet_ids
  description = "Public subnet IDs"
}

output "private_subnet_ids" {
  value       = module.networking.private_subnet_ids
  description = "Private subnet IDs"
}
