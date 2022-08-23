module "identifiers" {
  source = "./../modules/identifiers"

  aws_account_id = local.aws_account_id
  env            = var.env
  github_repo    = var.github_repo
  owner          = var.owner
}
