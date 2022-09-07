output "s3_bucket" {
  value = aws_s3_bucket.bucket.id
}

output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.bucket_distribution.id
}

output "cloudfront_distribution_domain" {
  value = aws_cloudfront_distribution.bucket_distribution.domain_name
}

output "cloudfront_distribution_alias" {
    value = local.cloudfront_distribution_alias
}
