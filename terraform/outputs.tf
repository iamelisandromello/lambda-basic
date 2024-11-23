output "lambda_arn" {
  value = aws_lambda_function.my_lambda_function.arn
}

output "bucket_suffix" {
  value = random_id.bucket_suffix.hex
}