variable "aws_region" {
    type        = string
    description = "The region were this website will be deployed to."
    default     = "eu-central-1"
}

variable "env" {
  type        = string
  description = "The name of the environment (namespace)."
}

variable "github_repo" {
  type        = string
  description = "The name of the current github repository, for example: saragerion/serverless-voting-app."
}

variable "owner" {
  type        = string
  description = "The name of the owner of this website."
}

variable "okta_org_name" {
    type        = string
    description = "The name of the OKTA org, example 'sara-dev-1234566'"
}

variable "okta_base_url" {
    type        = string
    description = "The base url for your org, example 'dev-1234567.okta.com'"
    sensitive = true
}

variable "okta_api_token" {
    type        = string
    description = "The OKTA API token"
    sensitive = true
}

variable "website_redirect_url_domain" {
    type        = string
    description = "The base url for your org, example 'dev-1234567.okta.com'"
    sensitive = true
}

