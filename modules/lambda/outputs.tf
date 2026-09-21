output "function_arns" {
  value = {
    for name, fn in aws_lambda_function.functions :
    name => fn.arn
  }
  description = "Lambda function ARNs"
}

output "function_names" {
  value = {
    for name, fn in aws_lambda_function.functions :
    name => fn.function_name
  }
  description = "Lambda function names"
}

output "invoke_arns" {
  value = {
    for name, fn in aws_lambda_function.functions :
    name => fn.invoke_arn
  }
  description = "Lambda function invoke ARNs"
}

output "function_details" {
  value = {
    for name, config in var.lambda_functions :
    name => {
      arn       = aws_lambda_function.functions[name].arn
      name      = aws_lambda_function.functions[name].function_name
      route     = config.route
      method    = config.http_method
    }
  }
  description = "Lambda function details for ALB/API Gateway"
}

output "all_function_names" {
  value       = [for fn in aws_lambda_function.functions : fn.function_name]
  description = "Names of all deployed Lambda functions"
}
