resource "aws_acm_certificate" "cert" {
  domain_name       = "*.${var.domain_name}"
  validation_method = "DNS"
  
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = var.zone_id
  name    = each.value.name
  type    = each.value.type
  records = [each.value.record]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

resource "aws_route53_record" "char_counter_alias" {
  zone_id = var.zone_id
  name    = "counter.${var.domain_name}"
  type    = "A"
  
  alias {
    name                   = aws_cloudfront_distribution.char_counter_cf.domain_name
    zone_id                = aws_cloudfront_distribution.char_counter_cf.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "json_validator_alias" {
  zone_id = var.zone_id
  name    = "validator.${var.domain_name}"
  type    = "A"
  
  alias {
    name                   = aws_cloudfront_distribution.json_validator_cf.domain_name
    zone_id                = aws_cloudfront_distribution.json_validator_cf.hosted_zone_id
    evaluate_target_health = false
  }
}
