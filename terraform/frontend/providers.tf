terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 2.3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "aws" {
    alias  = "aws_us_east_1"
    region = "us-east-1"
}

provider "random" {}
