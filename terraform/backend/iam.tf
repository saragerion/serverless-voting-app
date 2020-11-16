data "aws_iam_policy_document" "lambda_assume_role_policy_document" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]

    principals {
      identifiers = [
        "lambda.amazonaws.com"
      ]
      type = "Service"
    }
  }
}
