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

variable "okta_app_domain" {
  type        = string
  description = "The base url for your org, example 'dev-1234567.okta.com'"
}

variable "videos_global_table" {
  type        = string
  description = "Name of videos global table "
}

variable "votes_global_table" {
  type        = string
  description = "Name of votes global table"
}

variable "displayed_videos_index_name" {
  type        = string
  description = "Displayed index name of video global table"
}