output "api_url" {
  value = aws_apigatewayv2_api.api.api_endpoint
}

output "api_prefix" {
  value = aws_apigatewayv2_stage.stage.name
}
