resource "aws_lambda_function" "lambda_health" {
  filename         = "lambda.zip"
  function_name    = "${local.verbose_service_name}-health-${local.resource_name_postfix}"
  role             = aws_iam_role.lambda_health_role.arn
  handler          = "index.handler"
  runtime          = "nodejs12.x"
  source_code_hash = filebase64sha256("lambda.zip")

  environment {
    variables = {
      foo = "bar"
    }
  }

  tags = local.tags
}

resource "aws_iam_role" "lambda_health_role" {
  name               = "${local.verbose_service_name}-health-${local.resource_name_postfix}"
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
