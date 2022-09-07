output "state_aws_region" {
  value = var.aws_region
}

output "state_s3_bucket" {
  value = aws_s3_bucket.bucket.bucket
}

output "state_dynamodb_table" {
  value = aws_dynamodb_table.table.name
}
