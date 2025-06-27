output "iam_role_name" {
  value = aws_iam_role.cloudlingo_translate_role.name
}

output "iam_policy_name" {
  value = aws_iam_policy.cloudlingo_policy.name
}

output "request_bucket_name" {
  value = aws_s3_bucket.request_bucket.bucket
}

output "response_bucket_name" {
  value = aws_s3_bucket.response_bucket.bucket
}

output "lambda_function_name" {
  value = aws_lambda_function.translate_function.function_name
}

output "upload_command" {
  description = "Run this command to upload input_sample.json to the request bucket"
  value       = "aws s3 cp sample-data/input_sample.json s3://${aws_s3_bucket.request_bucket.bucket}/"
}

