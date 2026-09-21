resource "aws_lb" "main" {
  name               = "cinfra-alb-${var.environment}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets            = var.subnet_ids

  enable_deletion_protection = false

  tags = merge(
    var.tags,
    {
      Name = "cinfra-alb"
    }
  )
}

resource "aws_lb_target_group" "lambda" {
  for_each = var.lambda_functions

  name        = substr("${each.key}-tg-${var.environment}", 0, 32)
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "lambda"

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    matcher             = "200"
  }

  tags = merge(
    var.tags,
    {
      Name = "${each.key}-tg"
    }
  )
}

resource "aws_lb_target_group_attachment" "lambda" {
  for_each = var.lambda_functions

  target_group_arn = aws_lb_target_group.lambda[each.key].arn
  target_id        = split(":", each.value.arn)[6]
}

resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "application/json"
      message_body = jsonencode({ error = "Not Found" })
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener_rule" "lambda_routes" {
  for_each = var.lambda_functions

  listener_arn = aws_lb_listener.main.arn
  priority     = index(keys(var.lambda_functions), each.key) + 1

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lambda[each.key].arn
  }

  condition {
    path_pattern {
      values = ["${each.value.route}*"]
    }
  }
}

resource "aws_lambda_permission" "alb" {
  for_each = var.lambda_functions

  statement_id  = "AllowALBInvoke"
  action        = "lambda:InvokeFunction"
  function_name = each.value.name
  principal     = "elasticloadbalancing.amazonaws.com"
  source_arn    = aws_lb_target_group.lambda[each.key].arn
}
