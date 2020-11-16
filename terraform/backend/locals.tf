locals {
  aws_account_id = data.aws_caller_identity.current.account_id

  service_name         = module.identifiers.service_name
  verbose_service_name = module.identifiers.verbose_service_name
  stack_name_postfix   = module.identifiers.stack_name_postfix
  tags                 = module.identifiers.tags

  component_name = "api"
  api_uri_prefix = "api"

  dynamodb_diplayed_videos_index_name = "displayedVideosIndex"

  lambda_get_videos_resource_name = "${local.verbose_service_name}-get-videos-${local.stack_name_postfix}"
  apigw_resource_name             = "${local.verbose_service_name}-api-${local.stack_name_postfix}"
  dynamodb_videos_resource_name   = "${local.verbose_service_name}-videos-${local.stack_name_postfix}"
  dynamodb_votes_resource_name    = "${local.verbose_service_name}-votes-${local.stack_name_postfix}"
}
