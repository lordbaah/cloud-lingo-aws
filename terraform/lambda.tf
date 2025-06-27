# Package translate_handler.py into a zip automatically
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../lambda/translate_handler.py"
  output_path = "${path.module}/lambda/function.zip"
}


resource "aws_lambda_function" "translate_function" {
  function_name = "${var.project_name}-translate-func"
  role          = aws_iam_role.cloudlingo_translate_role.arn
  handler       = "translate_handler.lambda_handler"
  runtime       = "python3.12"

#file path
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  memory_size = 128
  timeout     = 10

   environment {
    variables = {
      REQUEST_BUCKET  = aws_s3_bucket.request_bucket.bucket
      RESPONSE_BUCKET = aws_s3_bucket.response_bucket.bucket
    }
  }


  tags = {
    Name        = "${var.project_name} Lambda Function"
    Environment = "Dev"
  }

  depends_on = [aws_iam_role_policy_attachment.cloudlingo_policy_attach]
}

#Add S3 Event Trigger
resource "aws_s3_bucket_notification" "trigger_lambda" {
  bucket = aws_s3_bucket.request_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.translate_function.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".json"
  }

  depends_on = [aws_lambda_permission.allow_s3_invoke]
}

# Allow S3 to Invoke Lambda
resource "aws_lambda_permission" "allow_s3_invoke" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.translate_function.function_name
  principal     = "s3.amazonaws.com"

  source_arn = aws_s3_bucket.request_bucket.arn
}

# Allow API Gateway to invoke Lambda
resource "aws_lambda_permission" "allow_api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.translate_function.function_name
  principal     = "apigateway.amazonaws.com"
}
