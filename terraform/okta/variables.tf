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

variable "frontend_website_url" {
    type        = string
    description = "The base url for your org, example 'https://d1nmd3ycyktnbq.cloudfront.net'"
}

