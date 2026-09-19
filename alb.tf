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

resource "aws_security_group" "lambda_sg" {
  name        = "cinfra-lambda-sg"
  description = "Security group for Lambda functions"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cinfra-lambda-sg"
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

# Create target groups dynamically
resource "aws_lb_target_group" "functions" {
  for_each    = var.lambda_functions
  name        = "${replace(each.key, "_", "-")}-tg"
  target_type = "lambda"

  tags = {
    Name = "${each.key}-target-group"
  }
}

# Create Lambda permissions for ALB invocation
resource "aws_lambda_permission" "alb_invoke" {
  for_each      = var.lambda_functions
  statement_id  = "AllowALBInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.functions[each.key].function_name
  principal     = "elasticloadbalancing.amazonaws.com"
  source_arn    = aws_lb_target_group.functions[each.key].arn
}

# Attach Lambda functions to target groups
resource "aws_lb_target_group_attachment" "functions" {
  for_each         = var.lambda_functions
  target_group_arn = aws_lb_target_group.functions[each.key].arn
  target_id        = aws_lambda_function.functions[each.key].arn
  depends_on       = [aws_lambda_permission.alb_invoke]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found - Available routes: ${join(", ", [for fn in var.lambda_functions : fn.route])}"
      status_code  = "404"
    }
  }
}

# Create listener rules dynamically
resource "aws_lb_listener_rule" "functions" {
  for_each     = var.lambda_functions
  listener_arn = aws_lb_listener.http.arn
  priority     = index(keys(var.lambda_functions), each.key) + 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.functions[each.key].arn
  }

  condition {
    path_pattern {
      values = [each.value.route]
    }
  }
}
