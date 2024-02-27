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

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
  default_tags {
    tags = var.aws_default_tags
  }
}

resource "random_id" "id" {
  byte_length = 8
}

locals {
  api_name         = var.domain_name != "" ? "${var.domain_name}" : "api-${random_id.id.hex}"
  parent_directory = abspath("${dirname(path.module)}/..")
}
