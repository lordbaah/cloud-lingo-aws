# 1. Create HTTP API
resource "aws_apigatewayv2_api" "cloudlingo_api" {
  name          = "${var.project_name}-http-api"
  protocol_type = "HTTP"
}

# 2. Create integration with Lambda
resource "aws_apigatewayv2_integration" "cloudlingo_integration" {
  api_id                         = aws_apigatewayv2_api.cloudlingo_api.id
  integration_type               = "AWS_PROXY"
  connection_type                = "INTERNET"
  description                    = "Lambda integration for CloudLingo translation"
  integration_method             = "POST"
  integration_uri                = aws_lambda_function.translate_function.invoke_arn
  passthrough_behavior           = "WHEN_NO_MATCH"
}

# 3. Create route (POST /translate)
resource "aws_apigatewayv2_route" "cloudlingo_route" {
  api_id    = aws_apigatewayv2_api.cloudlingo_api.id
  route_key = "POST /translate"

  target = "integrations/${aws_apigatewayv2_integration.cloudlingo_integration.id}"
}

# 4. Create a stage (auto-deploy enabled)
resource "aws_apigatewayv2_stage" "default_stage" {
  api_id      = aws_apigatewayv2_api.cloudlingo_api.id
  name        = "$default"
  auto_deploy = true
}
