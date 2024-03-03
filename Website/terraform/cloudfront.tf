# AWS Managed Caching Policies for CloudFront
data "aws_cloudfront_cache_policy" "cache-none" {
  name = "Managed-CachingDisabled"
}

data "aws_cloudfront_cache_policy" "cache-optimized" {
  name = "Managed-CachingOptimized"
}


resource "aws_cloudfront_distribution" "web" {
  provider = aws.us-east-1
  origin {
    domain_name              = aws_s3_bucket.website.bucket_regional_domain_name
    origin_id                = "S3-OriginID-${aws_s3_bucket.website.id}"
    origin_access_control_id = aws_cloudfront_origin_access_control.web.id
  }

  aliases = local.alias_list

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = var.cloudfront_default_root_object

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    target_origin_id       = "S3-OriginID-${aws_s3_bucket.website.id}"
    cache_policy_id        = data.aws_cloudfront_cache_policy.cache-optimized.id
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
  }

  # because React uses index.html to load the dynamically named content files (css + js), 
  # we'r setting a no cache policy on the index.html file, so that we don't have to wait for 
  # the cache to expire before any updates to our website are viewable in the browser
  ordered_cache_behavior {
    path_pattern           = "/index.html"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    target_origin_id       = "S3-OriginID-${aws_s3_bucket.website.id}"
    cache_policy_id        = data.aws_cloudfront_cache_policy.cache-none.id
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
  }

  price_class = var.cloudfront_price_class

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # # fall back to the cloudfront_default_certificate if we didn't create a cert for our custom domain
  viewer_certificate {
    acm_certificate_arn            = length(aws_acm_certificate.web) > 0 ? aws_acm_certificate.web[0].arn : null
    ssl_support_method             = length(aws_acm_certificate.web) > 0 ? "sni-only" : null
    minimum_protocol_version       = length(aws_acm_certificate.web) > 0 ? var.cloudfront_minimum_protocol_version : null
    cloudfront_default_certificate = length(aws_acm_certificate.web) > 0 ? null : true
  }

  dynamic "custom_error_response" {
    for_each = var.cloudfront_custom_error_responses
    content {
      error_code            = custom_error_response.value.error_code
      response_code         = custom_error_response.value.response_code
      error_caching_min_ttl = custom_error_response.value.error_caching_min_ttl
      response_page_path    = custom_error_response.value.response_page_path
    }
  }


  wait_for_deployment = false

  depends_on = [
    aws_acm_certificate.web,
    aws_acm_certificate_validation.web
  ]
}

resource "aws_cloudfront_origin_access_control" "web" {
  name                              = aws_s3_bucket.website.id
  description                       = "${aws_s3_bucket.website.id} Origin Access Control"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}
