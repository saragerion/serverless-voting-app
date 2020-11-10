resource "random_string" "resource_name_postfix" {
  length  = 16
  special = false
  upper   = false

  keepers = {
    env            = var.env
    aws_account_id = local.aws_account_id
    aws_region     = var.aws_region
  }
}
