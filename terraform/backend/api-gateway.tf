resource "aws_apigatewayv2_deployment" "deployment" {
  api_id      = aws_apigatewayv2_api.api.id
  description = local.apigw_resource_name

  triggers = {
    redeployment = sha1(join(",", tolist([
      jsonencode(aws_apigatewayv2_integration.get_videos),
      jsonencode(aws_apigatewayv2_route.get_videos),
    ])))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_apigatewayv2_api.api,
    aws_apigatewayv2_integration.get_videos,
    aws_apigatewayv2_route.get_videos
  ]
}

resource "aws_apigatewayv2_authorizer" "api" {
  api_id           = aws_apigatewayv2_api.api.id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]
  name             = local.apigw_resource_name

  jwt_configuration {
    audience = ["api://default"]
    issuer   = "https://${var.okta_base_url}/oauth2/default"
  }
}


resource "aws_apigatewayv2_api" "api" {
  name          = local.apigw_resource_name
  protocol_type = "HTTP"

  lifecycle {
    create_before_destroy = true
  }

  tags = local.tags
}

resource "aws_apigatewayv2_stage" "stage" {
  api_id        = aws_apigatewayv2_api.api.id
  name          = local.api_uri_prefix
  deployment_id = aws_apigatewayv2_deployment.deployment.id

  default_route_settings {
      throttling_burst_limit = 5000
      throttling_rate_limit = 10000
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_apigatewayv2_api.api,
    aws_apigatewayv2_deployment.deployment
  ]
}
