data "aws_caller_identity" "current" {}

data "terraform_remote_state" "self" {
  backend = "s3"

  config = {
    bucket = var.backend_bucket
    key    = var.backend_key
    region = var.backend_region
  }
}

data "aws_route53_zone" "hosted_zone" {
  name         = "${var.hosted_zone}."
  private_zone = false
}
