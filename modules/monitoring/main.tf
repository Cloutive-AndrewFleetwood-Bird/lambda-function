resource "aws_cloudwatch_log_group" "alb_logs" {
  name              = "/aws/alb/cinfra-alb-${var.environment}"
  retention_in_days = var.log_retention_days

  tags = merge(var.tags, { Name = "alb-logs" })
}

resource "aws_cloudwatch_metric_alarm" "alb_5xx_errors" {
  alarm_name          = "cinfra-alb-5xx-errors-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  statistic           = "Sum"
  threshold           = "5"
  alarm_description   = "Alert when ALB 5XX errors exceed threshold"

  dimensions = {
    LoadBalancer = var.alb_name
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "alb_target_unhealthy" {
  alarm_name          = "cinfra-alb-unhealthy-targets-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  statistic           = "Average"
  threshold           = "0"
  alarm_description   = "Alert when ALB targets are unhealthy"

  dimensions = {
    LoadBalancer = var.alb_name
  }

  tags = var.tags
}

# Lambda auto-creates log groups, but we can't manage them directly
# Instead, we can use aws_lambda_function's log_group_name output
# For now, just skip creating them - Lambda handles it
