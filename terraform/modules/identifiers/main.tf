resource "random_string" "stack_name_postfix" {
  length  = var.postfix_length
  special = false
  upper   = false

  keepers = {
    env            = var.env
    aws_account_id = var.aws_account_id
    aws_region     = var.aws_region
    length         = var.postfix_length
  }
}
