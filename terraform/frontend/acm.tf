resource "aws_acm_certificate" "website_domain" {
  domain_name       = "*.${var.hosted_zone}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = local.tags
}

resource "aws_route53_record" "website_domain_validation_record" {
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.hosted_zone.zone_id

  for_each = {
    for dvo in aws_acm_certificate.website_domain.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

}

resource "aws_acm_certificate_validation" "website_domain" {
  certificate_arn         = aws_acm_certificate.website_domain.arn
  validation_record_fqdns = [for record in aws_route53_record.website_domain_validation_record : record.fqdn]
}
