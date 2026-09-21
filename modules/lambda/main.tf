data "archive_file" "lambda_zip" {
  for_each = var.lambda_functions

  type        = "zip"
  source_dir  = "${path.module}/../../${each.value.path}"
  output_path = "${path.module}/../../${each.key}.zip"
}

resource "aws_lambda_function" "functions" {
  for_each = var.lambda_functions

  filename         = data.archive_file.lambda_zip[each.key].output_path
  source_code_hash = data.archive_file.lambda_zip[each.key].output_base64sha256
  function_name    = "cinfra-${each.key}-${var.environment}"
  role             = aws_iam_role.lambda_execution.arn
  handler          = each.value.handler
  runtime          = "python3.11"
  timeout          = var.lambda_timeout
  memory_size      = var.lambda_memory

  vpc_config {
    subnet_ids         = var.vpc_subnet_ids
    security_group_ids = [var.security_group_id]
  }

  environment {
    variables = {
      ENVIRONMENT = var.environment
    }
  }

  tags = merge(
    var.tags,
    {
      Name = each.key
    }
  )
}
