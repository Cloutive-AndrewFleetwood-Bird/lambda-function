resource "aws_wafv2_web_acl" "waf" {
  name        = "lambda-endpoints-waf"
  description = "WAF for Lambda Function URLs"
  scope       = "CLOUDFRONT"
  
  default_action {
    allow {}
  }
  
  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "lambda-waf-metric"
    sampled_requests_enabled   = false
  }

  rule {
    name     = "rate-limit"
    priority = 1
    
    action {
      block {}
    }
    
    statement {
      rate_based_statement {
        limit              = 100
        aggregate_key_type = "IP"
      }
    }
    
    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "rate-limit-metric"
      sampled_requests_enabled   = false
    }
  }
}

locals {
  char_counter_domain   = replace(replace(aws_lambda_function_url.char_counter_url.function_url, "https://", ""), "/", "")
  json_validator_domain = replace(replace(aws_lambda_function_url.json_validator_url.function_url, "https://", ""), "/", "")
}

resource "aws_cloudfront_distribution" "char_counter_cf" {
  enabled    = true
  aliases    = ["counter.${var.domain_name}"]
  web_acl_id = aws_wafv2_web_acl.waf.arn

  origin {
    domain_name = local.char_counter_domain
    origin_id   = "CharCounterOrigin"
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "CharCounterOrigin"

    forwarded_values {
      query_string = true
      cookies { forward = "none" }
    }
    viewer_protocol_policy = "redirect-to-https"
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.cert_validation.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction { restriction_type = "none" }
  }
}

resource "aws_cloudfront_distribution" "json_validator_cf" {
  enabled    = true
  aliases    = ["validator.${var.domain_name}"]
  web_acl_id = aws_wafv2_web_acl.waf.arn

  origin {
    domain_name = local.json_validator_domain
    origin_id   = "JsonValidatorOrigin"
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "JsonValidatorOrigin"

    forwarded_values {
      query_string = false
      headers      = ["Content-Type"]
      cookies { forward = "none" }
    }
    viewer_protocol_policy = "redirect-to-https"
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate_validation.cert_validation.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction { restriction_type = "none" }
  }
}
