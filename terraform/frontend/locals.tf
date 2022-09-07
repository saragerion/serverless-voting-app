locals {
  aws_account_id     = data.aws_caller_identity.current.account_id
  backend_api_domain = replace(lookup(data.terraform_remote_state.self.outputs, "api_url", "#"), "/^https?://([^/]*).*/", "$1")
  backend_api_prefix = lookup(data.terraform_remote_state.self.outputs, "api_prefix", "api")

  service_name         = module.identifiers.service_name
  verbose_service_name = module.identifiers.verbose_service_name
  stack_name_postfix   = module.identifiers.stack_name_postfix
  tags                 = module.identifiers.tags

  cloudfront_distribution_id = aws_cloudfront_distribution.bucket_distribution.id

  cloudfront_distribution_alias = "${local.verbose_service_name}.${var.hosted_zone}"

  component_name    = "frontend"
  website_origin_id = "${local.verbose_service_name}-website"
  api_origin_id     = "${local.verbose_service_name}-api"
}
