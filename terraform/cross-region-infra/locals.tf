locals {
  aws_account_id = data.aws_caller_identity.current.account_id

  service_name         = module.identifiers.service_name
  verbose_service_name = module.identifiers.verbose_service_name
  stack_name_postfix   = module.identifiers.stack_name_postfix
  tags                 = module.identifiers.tags

  component_name = "cross-region-infra"
  
  # Flag to determine if this stack is a primary region
  # If true, we will create a global DDB table with a replica table
  # else we will create no DDB table
  primary_region = "eu-central-1"
  secondary_region = "us-east-1"
  is_primary = (var.aws_region == local.primary_region) ? true: false

  dynamodb_displayed_videos_index_name = "displayedVideosIndex"

  # The name has to always the same or the resources will be deleted when deploying on the secondary region
  dynamodb_videos_resource_name   = "${local.service_name}-${var.env}-${local.primary_region}-videos-global-${local.stack_name_postfix}"
  dynamodb_votes_resource_name    = "${local.service_name}-${var.env}-${local.primary_region}-votes-global-${local.stack_name_postfix}"
}
