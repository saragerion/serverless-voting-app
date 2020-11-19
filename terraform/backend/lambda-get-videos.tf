resource "aws_lambda_function" "get_videos" {
  filename         = "./../../dist/backend/lambda_functions.zip"
  function_name    = local.lambda_get_videos_resource_name
  role             = aws_iam_role.get_videos.arn
  handler          = "get-videos.handler"
  runtime          = "nodejs12.x"
  source_code_hash = filebase64sha256("./../../dist/backend/lambda_functions.zip")
    memory_size = 256

    environment {
    variables = {
      TABLE_NAME_VIDEOS                   = local.dynamodb_videos_resource_name,
      DISPLAYED_VIDEOS_INDEX_NAME         = local.dynamodb_diplayed_videos_index_name,
      AWS_NODEJS_CONNECTION_REUSE_ENABLED = "1"
    }
  }

  depends_on = [
    aws_iam_role.get_videos,
  ]

  tags = local.tags
}

resource "aws_iam_role" "get_videos" {
  name               = local.lambda_get_videos_resource_name
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy_document.json

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "query_dynamodb" {
  role       = local.lambda_get_videos_resource_name
  policy_arn = aws_iam_policy.query_dynamodb.arn

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_iam_policy.query_dynamodb
  ]
}

resource "aws_iam_policy" "query_dynamodb" {
  name        = "${local.verbose_service_name}-query-dynamodb-${local.stack_name_postfix}"
  path        = "/"
  description = "IAM policy to query dynamodb from Lambda ${local.verbose_service_name}"

  lifecycle {
    create_before_destroy = true
  }

  policy = data.aws_iam_policy_document.query_dynamodb.json
}

data "aws_iam_policy_document" "query_dynamodb" {
  statement {
    actions = [
      "dynamodb:Query"
    ]

    resources = [
      "arn:aws:dynamodb:${var.aws_region}:${local.aws_account_id}:table/${local.dynamodb_videos_resource_name}/index/${local.dynamodb_diplayed_videos_index_name}",
    ]

    effect = "Allow"
  }
}

resource "aws_lambda_permission" "get_videos" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = local.lambda_get_videos_resource_name
  principal     = "apigateway.amazonaws.com"

  # TODO: recheck this permission
  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "${aws_apigatewayv2_api.api.execution_arn}/${local.api_uri_prefix}/*/*"

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_apigatewayv2_api.api
  ]
}

resource "aws_cloudwatch_log_group" "get_videos" {
  name              = "/aws/lambda/${local.lambda_get_videos_resource_name}"
  retention_in_days = 14

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "get_videos" {
  role       = local.lambda_get_videos_resource_name
  policy_arn = aws_iam_policy.lambda_logging.arn

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_iam_policy.lambda_logging
  ]
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "${local.verbose_service_name}-get-videos-logs-${local.stack_name_postfix}"
  path        = "/"
  description = "IAM policy for logging from Lambda ${local.verbose_service_name}"

  policy = data.aws_iam_policy_document.lambda_common_policy_document.json
}

data "aws_iam_policy_document" "lambda_common_policy_document" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "arn:aws:logs:${var.aws_region}:${local.aws_account_id}:log-group:/aws/lambda/${local.lambda_get_videos_resource_name}:*",
    ]

    effect = "Allow"
  }
}

resource "aws_apigatewayv2_integration" "get_videos" {
  api_id           = aws_apigatewayv2_api.api.id
  integration_type = "AWS_PROXY"

  description            = local.lambda_get_videos_resource_name
  passthrough_behavior   = "WHEN_NO_MATCH"
  integration_method     = "POST"
  integration_uri        = aws_lambda_function.get_videos.invoke_arn
  payload_format_version = "2.0"

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_apigatewayv2_api.api,
    aws_lambda_function.get_videos
  ]
}

resource "aws_apigatewayv2_route" "get_videos" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "GET /videos"

  target               = "integrations/${aws_apigatewayv2_integration.get_videos.id}"
//  authorizer_id        = aws_apigatewayv2_authorizer.api.id
//  authorization_type   = "JWT"
//  authorization_scopes = ["openid"]

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_apigatewayv2_api.api,
    aws_apigatewayv2_integration.get_videos
  ]
}
