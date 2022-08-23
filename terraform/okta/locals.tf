locals {

    aws_account_id     = data.aws_caller_identity.current.account_id

    verbose_service_name = module.identifiers.verbose_service_name
    stack_name_postfix   = module.identifiers.stack_name_postfix

    okta_app_resource_name = "${local.aws_account_id}-${local.verbose_service_name}-app-${local.stack_name_postfix}"

    tags = module.identifiers.tags
}
