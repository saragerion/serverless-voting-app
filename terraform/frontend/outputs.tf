output "s3_bucket" {
  value = aws_s3_bucket.bucket.id
}

output "cloudfront_distribution" {
  value = aws_cloudfront_distribution.bucket_distribution.id
}

output "website_domain" {
  value = aws_cloudfront_distribution.bucket_distribution.domain_name
}
