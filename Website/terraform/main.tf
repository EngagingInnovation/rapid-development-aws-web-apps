terraform {
  backend "local" {
    path = "tfstate/terraform.tfstate"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Your target AWS region
provider "aws" {
  region = var.aws_region
  profile = var.aws_profile
  default_tags {
    tags = var.aws_default_tags
  }
}

# Cloudfront needs the us-east-1 region
provider "aws" {
  region = "us-east-1"
  alias  = "us-east-1"
  default_tags {
    tags = var.aws_default_tags
  }
}

resource "random_id" "id" {
  byte_length = 8
}

locals {
  alias_list       = var.domain_name != "" ? (var.domain_name_with_www ? [var.domain_name, "www.${var.domain_name}"] : [var.domain_name]) : []
  alias_list_map   = { for name in local.alias_list : name => name }
  alias_list_certs = var.domain_name != "" ? (var.domain_name_with_www ? ["*.${var.domain_name}"] : []) : []
  s3_bucket_name   = var.s3_bucket_custom_name == "" ? var.domain_name : var.s3_bucket_custom_name
  s3_fallback_name = "webapp-template-${random_id.id.hex}"
  parent_directory = abspath("${dirname(path.module)}/..")
}
