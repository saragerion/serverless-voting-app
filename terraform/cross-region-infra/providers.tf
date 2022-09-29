terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}


provider "aws" {
  region = var.aws_region
}

# Provider can have only static alias so I hardcoded region value here.
# https://github.com/hashicorp/terraform/issues/9448
provider "aws" {
  alias = "eu-central-1"
  region = "eu-central-1"
}

provider "aws" {
  alias = "us-east-1"
  region = "us-east-1"
}

