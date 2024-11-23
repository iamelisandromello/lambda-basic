provider "aws" {
  region = "us-east-1" # Região desejada
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_lambda_function" "my_lambda" {
  function_name = "my_lambda_function"
  role          = aws_iam_role.lambda_execution_role.arn
  runtime       = "nodejs18.x"
  handler       = "handler.handler"

  filename = "${path.module}/build.zip" # Caminho para o ZIP da função Lambda
  source_code_hash = filebase64sha256("${path.module}/build.zip")

  environment {
    variables = {
      NODE_ENV = "production"
    }
  }
}

output "lambda_function_name" {
  value = aws_lambda_function.my_lambda.function_name
}
