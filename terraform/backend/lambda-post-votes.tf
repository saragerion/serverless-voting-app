resource "aws_lambda_function" "post_votes" {
  filename         = "./../../dist/backend/lambda_functions.zip"
  function_name    = local.lambda_post_votes_resource_name
  role             = aws_iam_role.post_votes.arn
  handler          = "post-votes.handler"
  runtime          = "nodejs14.x"
  source_code_hash = filebase64sha256("./../../dist/backend/lambda_functions.zip")
  memory_size      = 256

  environment {
    variables = {
      ENVIRONMENT                   = var.env
      AWS_ACCOUNT_ID                = local.aws_account_id
      TABLE_NAME_VIDEOS             = local.dynamodb_videos_resource_name,
      TABLE_NAME_VOTES              = local.dynamodb_votes_resource_name,
      POWERTOOLS_SERVICE_NAME       = local.powertools_service_name
      POWERTOOLS_LOGGER_LOG_LEVEL   = local.powertools_logger_log_level
      POWERTOOLS_LOGGER_SAMPLE_RATE = local.powertools_logger_sample_rate
      POWERTOOLS_METRICS_NAMESPACE  = local.powertools_metrics_namespace

    }
  }

  depends_on = [
    aws_iam_role.post_votes,
  ]

  tags = local.tags
}

resource "aws_iam_role" "post_votes" {
  name               = local.lambda_post_votes_resource_name
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy_document.json

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "write_dynamodb" {
  role       = local.lambda_post_votes_resource_name
  policy_arn = aws_iam_policy.write_dynamodb.arn

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_iam_policy.write_dynamodb
  ]
}

resource "aws_iam_policy" "write_dynamodb" {
  name        = "${local.verbose_service_name}-write-dynamodb-${local.stack_name_postfix}"
  path        = "/"
  description = "IAM policy to query DynamoDB from Lambda ${local.verbose_service_name}"

  lifecycle {
    create_before_destroy = true
  }

  policy = data.aws_iam_policy_document.write_dynamodb.json
}

data "aws_iam_policy_document" "write_dynamodb" {
  statement {
    actions = [
      "dynamodb:PutItem"
    ]

    resources = [
      "arn:aws:dynamodb:${var.aws_region}:${local.aws_account_id}:table/${local.dynamodb_votes_resource_name}",
    ]

    effect = "Allow"
  }

  statement {
    actions = [
      "dynamodb:UpdateItem"
    ]

    resources = [
      "arn:aws:dynamodb:${var.aws_region}:${local.aws_account_id}:table/${local.dynamodb_videos_resource_name}",
    ]

    effect = "Allow"
  }
}

resource "aws_lambda_permission" "post_votes" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = local.lambda_post_votes_resource_name
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

resource "aws_cloudwatch_log_group" "post_votes" {
  name              = "/aws/lambda/${local.lambda_post_votes_resource_name}"
  retention_in_days = 14

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy_attachment" "post_votes" {
  role       = local.lambda_post_votes_resource_name
  policy_arn = aws_iam_policy.lambda_post_votes_logging.arn

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_iam_policy.lambda_post_votes_logging
  ]
}

resource "aws_iam_policy" "lambda_post_votes_logging" {
  name        = "${local.verbose_service_name}-post-votes-logs-${local.stack_name_postfix}"
  path        = "/"
  description = "IAM policy for logging from Lambda ${local.verbose_service_name}"

  policy = data.aws_iam_policy_document.lambda_post_votes_policy_document.json
}

data "aws_iam_policy_document" "lambda_post_votes_policy_document" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "arn:aws:logs:${var.aws_region}:${local.aws_account_id}:log-group:/aws/lambda/${local.lambda_post_votes_resource_name}:*",
    ]

    effect = "Allow"
  }
}

resource "aws_apigatewayv2_integration" "post_votes" {
  api_id           = aws_apigatewayv2_api.api.id
  integration_type = "AWS_PROXY"

  description            = local.lambda_post_votes_resource_name
  passthrough_behavior   = "WHEN_NO_MATCH"
  integration_method     = "POST"
  integration_uri        = aws_lambda_function.post_votes.invoke_arn
  payload_format_version = "2.0"


  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_apigatewayv2_api.api,
    aws_lambda_function.post_votes
  ]
}

resource "aws_apigatewayv2_route" "post_votes" {
  api_id = aws_apigatewayv2_api.api.id

  route_key            = "POST /votes"
  target               = "integrations/${aws_apigatewayv2_integration.post_votes.id}"
  authorizer_id        = aws_apigatewayv2_authorizer.api.id
  authorization_type   = "JWT"
  authorization_scopes = ["openid"]

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_apigatewayv2_api.api,
    aws_apigatewayv2_integration.post_votes
  ]
}
