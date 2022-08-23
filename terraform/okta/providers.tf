terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    okta = {
        source = "okta/okta"
        version = "~> 3.20"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "okta" {
    org_name  = var.okta_org_name
    base_url  = var.okta_base_url
    api_token = var.okta_api_token
}
