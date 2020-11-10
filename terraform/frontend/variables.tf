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
  description = "The name of the owner of this service."
}

variable "backend_region" {
  type        = string
  description = "The region of the terraform state"
}

variable "backend_bucket" {
  type        = string
  description = "The bucket name of the terraform state"
}

variable "backend_key" {
  type        = string
  description = "The bucket key of the terraform state"
}
