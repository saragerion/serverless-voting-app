variable "aws_region" {
  type        = string
  description = "The region were this website will be deployed to."
  default     = "eu-central-1"
}

variable "env" {
  type        = string
  description = "The name of the environment (namespace)."
}

variable "aws_account_id" {
  type        = number
  description = "The ID of the AWS account where we are deploying to."
}

variable "github_repo" {
  type        = string
  description = "The name of the current github repository, for example: saragerion/serverless-voting-app"
}

variable "owner" {
  type        = string
  description = "The name of the owner of this website."
}

variable "component_name" {
  type        = string
  description = "The name of the current service component, for example: api"
  default     = "default"
}

variable "postfix_length" {
  type        = number
  description = "The length of the postfix string"
  default     = 12
}
