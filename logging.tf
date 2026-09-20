# CloudWatch Log Groups for Lambda functions (if you want explicit management)
resource "aws_cloudwatch_log_group" "lambda_logs" {
  for_each            = var.lambda_functions
  name                = "/aws/lambda/${aws_lambda_function.functions[each.key].function_name}"
  retention_in_days   = var.log_retention_days
  skip_destroy        = false

  tags = merge(
    var.tags,
    {
      Name        = "${each.key}-logs"
      Environment = var.environment
    }
  )
}
