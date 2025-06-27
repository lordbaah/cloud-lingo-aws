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

#utput full usable API endpoint for /translate
output "cloudlingo_api_url" {
  value = "${aws_apigatewayv2_api.cloudlingo_api.api_endpoint}/translate"
}

# Output final static site URL and bucket name
output "cloudlingo_frontend_url" {
  value = "https://${aws_cloudfront_distribution.frontend.domain_name}"
}

output "cloudlingo_frontend_bucket_name" {
  value = aws_s3_bucket.frontend.bucket
}