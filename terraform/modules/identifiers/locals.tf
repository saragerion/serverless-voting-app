locals {
  service_name         = element(split("/", var.github_repo), 1)
  verbose_service_name = "${local.service_name}-${var.env}-${var.aws_region}"
  stack_name_postfix   = random_string.stack_name_postfix.result

  tags = {
    Service      = local.service_name
    Component    = var.component_name
    Environment  = var.env
    ManagedBy    = "Terraform"
    GithubRepo   = var.github_repo
    Owner        = var.owner
    AwsRegion    = var.aws_region
    AwsAccountId = var.aws_account_id
  }
}
