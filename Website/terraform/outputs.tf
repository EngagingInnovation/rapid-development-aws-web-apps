output "acm_certificate_id" {
  value = length(aws_acm_certificate.web) > 0 ? aws_acm_certificate.web[0].id : "cloudfront_default_certificate"
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.web.domain_name
}

output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.web.id
}

output "s3_bucket_arn" {
  value = aws_s3_bucket.website.arn
}

output "s3_bucket_id" {
  value = aws_s3_bucket.website.id
}

output "web_url" {
  value = format("https://%s", var.domain_name != "" ? var.domain_name : aws_cloudfront_distribution.web.domain_name)
}