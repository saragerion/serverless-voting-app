resource "aws_apigatewayv2_api" "api" {
  name          = "${local.verbose_service_name}-api-${local.resource_name_postfix}"
  protocol_type = "HTTP"

  tags = local.tags
}

resource "aws_apigatewayv2_integration" "lambda_health" {
  api_id           = aws_apigatewayv2_api.api.id
  integration_type = "AWS"

  connection_type           = "INTERNET"
  content_handling_strategy = "CONVERT_TO_TEXT"
  description               = "${local.verbose_service_name}-integration-${local.resource_name_postfix}"
  integration_method        = "POST"
  integration_uri           = aws_lambda_function.lambda_health.invoke_arn
  passthrough_behavior      = "NEVER"
}

resource "aws_apigatewayv2_stage" "stage" {
  api_id = aws_apigatewayv2_api.api.id
  name   = "default"
}

resource "aws_apigatewayv2_route" "health" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "$default"
}

resource "aws_apigatewayv2_deployment" "deployment" {
  api_id      = aws_apigatewayv2_api.api.id
  description = "${local.verbose_service_name}-deployment-${local.resource_name_postfix}"

  triggers = {
    redeployment = sha1(join(",", list(
      jsonencode(aws_apigatewayv2_integration.lambda_health),
      jsonencode(aws_apigatewayv2_route.health),
    )))
  }

  lifecycle {
    create_before_destroy = true
  }
}

