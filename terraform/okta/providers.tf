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

provider "okta" {}
