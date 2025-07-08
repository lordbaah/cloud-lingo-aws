resource "aws_apigatewayv2_api" "cloudlingo_api" {
  name          = "${var.project_name}-http-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins     = ["https://${aws_cloudfront_distribution.frontend.domain_name}"]
    allow_methods     = ["POST", "OPTIONS"]
    allow_headers     = [
      "Content-Type",
      "Authorization",
      "X-Amz-Date",
      "X-Api-Key",
      "X-Amz-Security-Token"
    ]
    expose_headers    = ["Content-Type"]
    max_age           = 3600
    allow_credentials = false
  }
}

resource "aws_apigatewayv2_integration" "cloudlingo_integration" {
  api_id             = aws_apigatewayv2_api.cloudlingo_api.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.translate_function.invoke_arn
  integration_method = "POST"
  payload_format_version = "2.0"
  connection_type    = "INTERNET"
}

# ANY route for translation (handles both POST and OPTIONS)
resource "aws_apigatewayv2_route" "cloudlingo_any_route" {
  api_id    = aws_apigatewayv2_api.cloudlingo_api.id
  route_key = "ANY /translate"
  target    = "integrations/${aws_apigatewayv2_integration.cloudlingo_integration.id}"
}

resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.cloudlingo_api.id
  name        = "$default"
  auto_deploy = true

  # Optional: Enable logging for debugging
  default_route_settings {
    logging_level            = "INFO"
    data_trace_enabled       = true
    detailed_metrics_enabled = true
    throttling_rate_limit    = 1000
    throttling_burst_limit   = 2000
  }

  depends_on = [aws_cloudwatch_log_group.api_gateway_logs]
}

# CloudWatch log group for API Gateway logs (optional but recommended)
resource "aws_cloudwatch_log_group" "api_gateway_logs" {
  name              = "/aws/apigateway/${var.project_name}-http-api"
  retention_in_days = 14
}