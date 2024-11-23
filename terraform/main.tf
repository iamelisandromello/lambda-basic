provider "aws" {
  region = "us-east-1"  # Ou qualquer região desejada
}

# Geração de ID aleatório para garantir nome único do bucket
resource "random_id" "bucket_suffix" {
  byte_length = 8
}

# Geração de ID aleatório para garantir nome único da role
resource "random_id" "lambda_role_suffix" {
  byte_length = 8
}

# Geração de ID aleatório para garantir nome único do log group
resource "random_id" "lambda_log_group_suffix" {
  byte_length = 8
}

# Criação do Bucket S3 onde o código será armazenado
resource "aws_s3_bucket" "lambda_code_bucket" {
  bucket = "meu-unico-bucket-s3-${random_id.bucket_suffix.hex}"  # Nome único para o bucket
}

# Role para a Lambda
resource "aws_iam_role" "lambda_execution_role" {
  name               = "lambda_execution_role_v2-${random_id.lambda_role_suffix.hex}"  # Nome único para a role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

# Função Lambda que utiliza o código no S3
resource "aws_lambda_function" "my_lambda_function" {
  function_name = "my_lambda_function"

  # Referência ao arquivo ZIP do código da Lambda armazenado no S3
  s3_bucket = aws_s3_bucket.lambda_code_bucket.bucket
  s3_key    = "path/to/lambda.zip"  # O caminho do arquivo dentro do S3

  handler = "index.handler"  # O handler que será executado
  runtime = "nodejs16.x"     # O runtime da Lambda (nodejs16.x ou outro)

  role = aws_iam_role.lambda_execution_role.arn  # Role para execução
}

# Política de logs para a Lambda
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name = "/aws/lambda/my_lambda_function-${random_id.lambda_log_group_suffix.hex}"  # Nome único para o log group
}

# Output para o nome do bucket
output "bucket_name" {
  value = aws_s3_bucket.lambda_code_bucket.bucket
}

output "lambda_arn" {
  value = aws_lambda_function.my_lambda_function.arn
}
