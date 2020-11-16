resource "aws_lambda_function" "lambda_health" {
  filename         = "lambda_function.zip"
  function_name    = "${local.verbose_service_name}-health-${local.stack_name_postfix}"
  role             = aws_iam_role.lambda_health_role.arn
  handler          = "index.handler"
  runtime          = "nodejs12.x"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      foo = "bar"
    }
  }

  tags = local.tags
}

resource "aws_iam_role" "lambda_health_role" {
  name               = "${local.verbose_service_name}-health-${local.stack_name_postfix}"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy_document.json

  tags = local.tags
}

resource "aws_cloudwatch_log_group" "lambda_health_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.lambda_health.function_name}"
  retention_in_days = 14
}

resource "aws_iam_policy" "lambda_common_policy" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = data.aws_iam_policy_document.lambda_common_policy_document.json
}

resource "aws_iam_role_policy_attachment" "lambda_common_policy_attachment" {
  role       = aws_iam_role.lambda_health_role.name
  policy_arn = aws_iam_policy.lambda_common_policy.arn
}

resource "aws_lambda_permission" "apigw_lambda" {
    statement_id  = "AllowExecutionFromAPIGateway"
    action        = "lambda:InvokeFunction"
    function_name = aws_lambda_function.lambda_health.function_name
    principal     = "apigateway.amazonaws.com"

    # TODO: recheck this permission
    # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
    source_arn = "${aws_apigatewayv2_api.api.execution_arn}/${aws_apigatewayv2_stage.stage.name}/*/*"
}
