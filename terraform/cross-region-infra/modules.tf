module "identifiers" {
  source = "./../modules/identifiers"

  aws_account_id = local.aws_account_id
  aws_region     = var.aws_region
  env            = var.env
  github_repo    = var.github_repo
  owner          = var.owner
  component_name = local.component_name
}
