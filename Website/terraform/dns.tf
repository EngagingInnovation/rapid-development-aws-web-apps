resource "aws_acm_certificate" "web" {
  count                     = var.domain_name != "" ? 1 : 0
  provider                  = aws.us-east-1
  domain_name               = var.domain_name
  subject_alternative_names = local.alias_list_certs
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
    precondition {
      condition     = (var.domain_name != "" && var.hostedzone_id != "")
      error_message = "A Hosted Zone ID variable (var.hostedzone_id) must be set if the var.domain_name is set"
    }
  }
}

resource "aws_route53_record" "validation" {
  # Use a conditional expression to check if aws_acm_certificate.this exists.
  # If it does, iterate over its domain_validation_options. Otherwise, provide an empty map.
  for_each = length(aws_acm_certificate.web) > 0 ? {
    for dvo in aws_acm_certificate.web[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  } : {}

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.hostedzone_id
}


resource "aws_acm_certificate_validation" "web" {
  count                   = length(aws_acm_certificate.web) > 0 ? 1 : 0
  provider                = aws.us-east-1
  certificate_arn         = aws_acm_certificate.web[0].arn
  validation_record_fqdns = [for record in aws_route53_record.validation : record.fqdn]
}


resource "aws_route53_record" "domain_name_records" {
  for_each = length(local.alias_list) > 0 ? local.alias_list_map : {}

  type    = "A"
  zone_id = var.hostedzone_id
  name    = each.key

  alias {
    name                   = aws_cloudfront_distribution.web.domain_name
    zone_id                = "Z2FDTNDATAQYW2"
    evaluate_target_health = false
  }
}
