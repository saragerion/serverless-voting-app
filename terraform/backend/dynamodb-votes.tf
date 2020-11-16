resource "aws_dynamodb_table" "votes" {
    name           = "${local.verbose_service_name}-votes-${local.stack_name_postfix}"
    billing_mode   = "PAY_PER_REQUEST"
    hash_key       = "userId"
    range_key      = "replayId"

    attribute {
        name = "userId"
        type = "S"
    }

    attribute {
        name = "replayId"
        type = "S"
    }

    tags = local.tags
}
