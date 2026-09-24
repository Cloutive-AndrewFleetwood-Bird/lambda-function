output "alb_log_group_name" {
  value       = aws_cloudwatch_log_group.alb_logs.name
  description = "ALB log group name"
}

output "lambda_log_group_names" {
  value = {
    for name in var.lambda_function_names :
    name => "/aws/lambda/${name}"
  }
  description = "Lambda log group names (auto-created by Lambda)"
}
