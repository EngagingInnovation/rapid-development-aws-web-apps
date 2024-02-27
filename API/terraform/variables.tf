# Most Commonly Used Variables for Application Configuration
#
variable "auth_allowed_users" {
  type        = string
  description = "comma separated list of allowed emails for the auth function"
  default     = "let@me.in"
}

variable "cors_allowed_origins" {
  type        = list(string)
  description = "List of allowed origins for CORS"
  default = []
}

variable "domain_name" {
  type        = string
  description = "Domain name for website, used for all resources"
  default     = ""
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

variable "aws_profile" {
  type        = string
  description = "AWS profile to use"
  default     = "default"
}

variable "aws_region" {
  type        = string
  description = "Region for resources"
  default     = "us-west-2"
}

variable "lambda_api_name" {
  type        = string
  description = "Name for the lambda that will return content for this API"
  default     = "webapp-template-fn-api-content"
}

variable "lambda_auth_name" {
  type        = string
  description = "Name for the lambda that will provide Auth, protecting the API"
  default     = "webapp-template-fn-api-auth"
}

