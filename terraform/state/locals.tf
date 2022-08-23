locals {
    aws_account_id = data.aws_caller_identity.current.account_id

    s3_bucket_resource_name      = "${local.aws_account_id}-terraform-state-bucket"
    dynamodb_table_resource_name = "${local.aws_account_id}-terraform-state-table"

    tags = module.identifiers.tags
}
