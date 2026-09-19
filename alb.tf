resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Allow inbound HTTP traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "main" {
  name               = "cinfra-services-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = data.aws_subnets.default.ids
}

# --- Target Groups ---
resource "aws_lb_target_group" "char_counter_tg" {
  name        = "char-counter-tg"
  target_type = "lambda"
}

resource "aws_lb_target_group" "json_validator_tg" {
  name        = "json-validator-tg"
  target_type = "lambda"
}

resource "aws_lb_target_group_attachment" "char_counter_att" {
  target_group_arn = aws_lb_target_group.char_counter_tg.arn
  target_id        = aws_lambda_function.char_counter.arn
  depends_on       = [aws_lambda_permission.alb_char_counter]
}

resource "aws_lb_target_group_attachment" "json_validator_att" {
  target_group_arn = aws_lb_target_group.json_validator_tg.arn
  target_id        = aws_lambda_function.json_validator.arn
  depends_on       = [aws_lambda_permission.alb_json_validator]
}

# --- Listeners & Path-Based Routing ---
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found - Use /count or /validate"
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener_rule" "route_char_counter" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.char_counter_tg.arn
  }

  condition {
    path_pattern {
      values = ["/count"]
    }
  }
}

resource "aws_lb_listener_rule" "route_json_validator" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.json_validator_tg.arn
  }

  condition {
    path_pattern {
      values = ["/validate"]
    }
  }
}
