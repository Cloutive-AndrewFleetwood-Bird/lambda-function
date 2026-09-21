resource "aws_apigatewayv2_api" "main" {
  name          = "cinfra-api-${var.environment}"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST", "OPTIONS"]
    allow_headers = ["Content-Type"]
    max_age       = 300
  }

  tags = merge(
    var.tags,
    {
      Name        = "cinfra-api"
      Environment = var.environment
    }
  )
}

resource "aws_apigatewayv2_integration" "lambda" {
  for_each = var.lambda_functions

  api_id             = aws_apigatewayv2_api.main.id
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
  payload_format_version = "2.0"
  integration_uri    = var.invoke_arns[each.key]
}

resource "aws_apigatewayv2_route" "lambda" {
  for_each = var.lambda_functions

  api_id    = aws_apigatewayv2_api.main.id
  route_key = "${each.value.method} ${each.value.route}"
  target    = "integrations/${aws_apigatewayv2_integration.lambda[each.key].id}"
}

resource "aws_lambda_permission" "api_gateway" {
  for_each = var.lambda_functions

  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = each.value.name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.main.id
  name        = "$default"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_logs.arn
    format = jsonencode({
      requestId            = "$context.requestId"
      sourceIp             = "$context.identity.sourceIp"
      httpMethod           = "$context.httpMethod"
      resourcePath         = "$context.resourcePath"
      status               = "$context.status"
      responseLength       = "$context.responseLength"
      integrationLatency   = "$context.integration.latency"
      timestamp            = "$context.requestTime"
    })
  }

  tags = merge(var.tags, { Name = "api-stage" })
}

resource "aws_cloudwatch_log_group" "api_logs" {
  name              = "/aws/apigateway/cinfra-api-${var.environment}"
  retention_in_days = var.log_retention_days

  tags = merge(var.tags, { Name = "api-logs" })
}

resource "aws_cloudwatch_metric_alarm" "api_4xx_errors" {
  alarm_name          = "cinfra-api-4xx-errors-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "4XXError"
  namespace           = "AWS/ApiGateway"
  period              = "300"
  statistic           = "Sum"
  threshold           = "10"
  alarm_description   = "Alert when API 4XX errors exceed threshold"

  dimensions = {
    ApiName = aws_apigatewayv2_api.main.name
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "api_5xx_errors" {
  alarm_name          = "cinfra-api-5xx-errors-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "5XXError"
  namespace           = "AWS/ApiGateway"
  period              = "300"
  statistic           = "Sum"
  threshold           = "5"
  alarm_description   = "Alert when API 5XX errors exceed threshold"

  dimensions = {
    ApiName = aws_apigatewayv2_api.main.name
  }

  tags = var.tags
}
