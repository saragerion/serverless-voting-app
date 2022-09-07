resource "aws_acm_certificate" "website_domain" {
  domain_name       = var.hosted_zone
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = local.tags
}

resource "aws_route53_record" "website_domain" {
  name    = aws_acm_certificate.website_domain.domain_validation_options[0].resource_record_name
  type    = aws_acm_certificate.website_domain.domain_validation_options[0].resource_record_type
  zone_id = data.aws_route53_zone.hosted_zone.id
  records = [
    aws_acm_certificate.website_domain.domain_validation_options[0].resource_record_value
  ]
  ttl = 360
}

resource "aws_acm_certificate_validation" "website_domain" {
  certificate_arn = aws_acm_certificate.website_domain.arn
  validation_record_fqdns = [
    aws_route53_record.website_domain.fqdn
  ]
}
