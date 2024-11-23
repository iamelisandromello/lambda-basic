terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "random_id" "bucket_suffix" {
  byte_length = 8
}

resource "random_id" "lambda_role_suffix" {
  byte_length = 8
}

resource "random_id" "lambda_log_group_suffix" {
  byte_length = 8
}

resource "aws_s3_bucket" "lambda_code_bucket" {
  bucket = "meu-unico-bucket-s3-${random_id.bucket_suffix.hex}"
}

resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role_v2-${random_id.lambda_role_suffix.hex}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_lambda_function" "my_lambda_function" {
  function_name = "my_lambda_function"
  s3_bucket     = aws_s3_bucket.lambda_code_bucket.bucket
  s3_key        = "lambda.zip"
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  role          = aws_iam_role.lambda_execution_role.arn
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name = "/aws/lambda/my_lambda_function-${random_id.lambda_log_group_suffix.hex}"
}
