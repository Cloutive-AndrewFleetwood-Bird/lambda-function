# CloudWatch Logs for Lambda Functions
resource "aws_cloudwatch_log_group" "char_counter" {
  name              = "/aws/lambda/character-counter-service"
  retention_in_days = 7

  tags = {
    Name = "char-counter-logs"
  }
}

resource "aws_cloudwatch_log_group" "json_validator" {
  name              = "/aws/lambda/json-validator-service"
  retention_in_days = 7

  tags = {
    Name = "json-validator-logs"
  }
}

# Lambda Execution Role Policy for CloudWatch Logs
resource "aws_iam_role_policy" "lambda_cloudwatch_logs" {
  name = "lambda-cloudwatch-logs"
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/*"
      }
    ]
  })
}

data "aws_region" "current" {}
