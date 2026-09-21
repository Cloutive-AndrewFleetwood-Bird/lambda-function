output "alb_log_group_name" {
  value       = aws_cloudwatch_log_group.alb_logs.name
  description = "ALB log group name"
}

output "lambda_log_group_names" {
  value = {
    for name, lg in aws_cloudwatch_log_group.lambda_logs :
    name => lg.name
  }
  description = "Lambda log group names"
}
