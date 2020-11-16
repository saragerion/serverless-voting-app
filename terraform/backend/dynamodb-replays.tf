resource "aws_dynamodb_table" "replays" {
    name           = "${local.verbose_service_name}-replays-${local.stack_name_postfix}"
    billing_mode   = "PAY_PER_REQUEST"
    hash_key       = "replayId"

    attribute {
        name = "replayId"
        type = "S"
    }

    tags = local.tags
}
