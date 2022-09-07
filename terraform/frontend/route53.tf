resource "aws_route53_record" "cloudfront_distribution_alias" {
  zone_id = data.aws_route53_zone.hosted_zone.id
  name    = local.cloudfront_distribution_alias
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.bucket_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.bucket_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}
