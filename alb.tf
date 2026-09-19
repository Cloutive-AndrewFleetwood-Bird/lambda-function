variable "allowed_cidr" {
  description = "CIDR block allowed to access the ALB"
  type        = string
  default     = "0.0.0.0/0"  # Change this to your IP/CIDR, e.g., "203.0.113.0/32"
}

resource "aws_security_group" "alb_sg" {
  name        = "cinfra-alb-sg"
  description = "Security group for ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cinfra-alb-sg"
  }
}

resource "aws_s3_bucket" "alb_logs" {
  bucket = "cinfra-alb-logs-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name = "cinfra-alb-logs"
  }
}

resource "aws_s3_bucket_versioning" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_elb_service_account" "main" {}

resource "aws_s3_bucket_policy" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = data.aws_elb_service_account.main.arn
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.alb_logs.arn}/*"
      }
    ]
  })
}

resource "aws_lb" "main" {
  name               = "cinfra-services-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_1.id, aws_subnet.public_2.id]

  access_logs {
    bucket  = aws_s3_bucket.alb_logs.id
    enabled = true
  }

  depends_on = [aws_s3_bucket_policy.alb_logs]

  tags = {
    Name = "cinfra-alb"
  }
}

resource "aws_lb_target_group" "char_counter" {
  name        = "char-counter-tg"
  target_type = "lambda"
}

resource "aws_lb_target_group" "json_validator" {
  name        = "json-validator-tg"
  target_type = "lambda"
}

resource "aws_lambda_permission" "alb_char_counter" {
  statement_id  = "AllowALBInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.char_counter.function_name
  principal     = "elasticloadbalancing.amazonaws.com"
  source_arn    = aws_lb_target_group.char_counter.arn
}

resource "aws_lambda_permission" "alb_json_validator" {
  statement_id  = "AllowALBInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.json_validator.function_name
  principal     = "elasticloadbalancing.amazonaws.com"
  source_arn    = aws_lb_target_group.json_validator.arn
}

resource "aws_lb_target_group_attachment" "char_counter" {
  target_group_arn = aws_lb_target_group.char_counter.arn
  target_id        = aws_lambda_function.char_counter.arn
  depends_on       = [aws_lambda_permission.alb_char_counter]
}

resource "aws_lb_target_group_attachment" "json_validator" {
  target_group_arn = aws_lb_target_group.json_validator.arn
  target_id        = aws_lambda_function.json_validator.arn
  depends_on       = [aws_lambda_permission.alb_json_validator]
}

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

resource "aws_lb_listener_rule" "char_counter" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.char_counter.arn
  }

  condition {
    path_pattern {
      values = ["/count"]
    }
  }
}

resource "aws_lb_listener_rule" "json_validator" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.json_validator.arn
  }

  condition {
    path_pattern {
      values = ["/validate"]
    }
  }
}
