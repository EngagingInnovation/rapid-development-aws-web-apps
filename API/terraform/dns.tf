## DOMAIN NAMES
# Request an SSL Certificate for this domain
resource "aws_acm_certificate" "api" {
  count             = var.domain_name != "" ? 1 : 0
  domain_name       = var.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
    precondition {
      condition     = (var.domain_name != "" && var.hostedzone_id != "")
      error_message = "A Hosted Zone ID variable (var.hostedzone_id) must be set if the var.domain_name is set"
    }
  }
}

# Create DNS validation records
resource "aws_route53_record" "cert_validation" {
  for_each = length(aws_acm_certificate.api) > 0 ? {
    for dvo in aws_acm_certificate.api[0].domain_validation_options : dvo.domain_name => {
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

# Validate the SSL Certificate
resource "aws_acm_certificate_validation" "api" {
  count                   = length(aws_acm_certificate.api) > 0 ? 1 : 0
  certificate_arn         = aws_acm_certificate.api[0].arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

# Update Route53 Record to point to API Gateway V2
resource "aws_route53_record" "api_gateway_record" {
  count   = var.domain_name != "" ? 1 : 0
  name    = var.domain_name
  type    = "A"
  zone_id = var.hostedzone_id

  alias {
    name                   = aws_apigatewayv2_domain_name.api[0].domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.api[0].domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}
