resource "aws_iam_role" "lambda_exec" {
  name = "lambda_execution_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_vpc_execution" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

data "archive_file" "char_counter_zip" {
  type        = "zip"
  source_dir  = "${path.module}/char_counter"
  output_path = "${path.module}/char_counter.zip"
}

resource "aws_lambda_function" "char_counter" {
  filename         = data.archive_file.char_counter_zip.output_path
  function_name    = "character-counter-service"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.14"
  source_code_hash = data.archive_file.char_counter_zip.output_base64sha256

  vpc_config {
    subnet_ids         = [aws_subnet.private_1.id, aws_subnet.private_2.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }
}

data "archive_file" "json_validator_zip" {
  type        = "zip"
  source_dir  = "${path.module}/json_validator"
  output_path = "${path.module}/json_validator.zip"
}

resource "aws_lambda_function" "json_validator" {
  filename         = data.archive_file.json_validator_zip.output_path
  function_name    = "json-validator-service"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.14"
  source_code_hash = data.archive_file.json_validator_zip.output_base64sha256

  vpc_config {
    subnet_ids         = [aws_subnet.private_1.id, aws_subnet.private_2.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }
}
