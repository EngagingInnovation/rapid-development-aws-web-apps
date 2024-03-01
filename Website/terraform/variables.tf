# Most Commonly Used Variables for Application Configuration
#
variable "domain_name" {
  type        = string
  description = "Domain name for website, used for all resources"
  default     = ""
}

variable "domain_name_with_www" {
  type        = bool
  description = "Add alias 'www.(var.domain_name)' to our CloudFront distribution?"
  default     = false
}

variable "hostedzone_id" {
  type        = string
  description = "Hosted Zone ID for domain name"
  default     = ""
}


# Other AWS Resource Settings Available for Application Fine Tuning
#
variable "aws_default_tags" {
  type        = map(string)
  description = "Tags for all resources"
  default = {
    Terraform = "true"
  }
}

# If not set, Terraform looks for the environment variable "AWS_PROFILE"
# in our template, this variable is set during the Make build/deploy process. 
# The default AWS_PROFILE value is "default", but can be changed in the .makerc file
variable "aws_profile" {
  type        = string
  description = "AWS profile to use"
  default     = null
}

variable "aws_region" {
  type        = string
  description = "Region for resources"
  default     = "us-west-2"
}

variable "cloudfront_custom_error_responses" {
  type = list(object({
    error_code            = number
    response_code         = number
    error_caching_min_ttl = number
    response_page_path    = string
  }))
  description = "See https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/GeneratingCustomErrorResponses.html"
  default = [
    {
      error_code            = 403
      response_code         = 404
      error_caching_min_ttl = 10
      response_page_path    = "/index.html"
    },
    {
      error_code            = 404
      response_code         = 404
      error_caching_min_ttl = 10
      response_page_path    = "/index.html"
    }
  ]
}

variable "cloudfront_default_root_object" {
  type        = string
  description = "Default root object for cloudfront. Need to also provide custom error response if changing from default"
  default     = "index.html"
}

variable "cloudfront_minimum_protocol_version" {
  type        = string
  description = "The minimum version of the SSL protocol that you want CloudFront to use for HTTPS connections."
  default     = "TLSv1.2_2021"
}

variable "cloudfront_price_class" {
  type        = string
  description = "CloudFront distribution price class"
  default     = "PriceClass_100" # Only US,Canada,Europe
}

# All values for the TTL are important when uploading static content that changes
# https://stackoverflow.com/questions/67845341/cloudfront-s3-etag-possible-for-cloudfront-to-send-updated-s3-object-before-t
variable "cloudfront_ttl_default" {
  type        = number
  description = "The default TTL for the cloudfront cache; 86400 = 24 hours"
  default     = 86400
}

variable "cloudfront_ttl_min" {
  type        = number
  description = "The minimum TTL for the cloudfront cache"
  default     = 0
}

variable "cloudfront_ttl_max" {
  type        = number
  description = "The maximum TTL for the cloudfront cache; 31536000 = 1 year"
  default     = 31536000
}

variable "s3_bucket_custom_name" {
  type        = string
  description = "Any non-empty string here will replace default name of bucket `var.domain_name`"
  default     = ""
}

variable "s3_bucket_versioning" {
  type        = bool
  description = "Apply versioning to S3 bucket?"
  default     = false
}