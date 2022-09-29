locals {
  aws_account_id = data.aws_caller_identity.current.account_id

  service_name         = module.identifiers.service_name
  verbose_service_name = module.identifiers.verbose_service_name
  stack_name_postfix   = module.identifiers.stack_name_postfix
  tags                 = module.identifiers.tags

  component_name = "api"
  api_uri_prefix = "api"

  lambda_get_videos_resource_name = "${local.verbose_service_name}-get-videos-${local.stack_name_postfix}"
  lambda_post_votes_resource_name = "${local.verbose_service_name}-post-votes-${local.stack_name_postfix}"
  apigw_resource_name             = "${local.verbose_service_name}-api-${local.stack_name_postfix}"

  is_current_env_prod = (var.env == "prod") ? true : false

  powertools_service_name       = local.service_name
  powertools_logger_log_level   = local.is_current_env_prod ? "WARN" : "DEBUG"
  powertools_metrics_namespace  = "octank" // Dummy company name
  powertools_logger_sample_rate = local.is_current_env_prod ? "0.1" : "1"

}
