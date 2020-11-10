locals {
  aws_account_id = data.aws_caller_identity.current.account_id

  service_name         = module.identifiers.service_name
  verbose_service_name = module.identifiers.verbose_service_name
  stack_name_postfix   = module.identifiers.stack_name_postfix
  tags                 = module.identifiers.tags

  component_name = "api"
}
