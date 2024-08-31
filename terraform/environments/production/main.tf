terraform {
  required_version = ">=1.9.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0"
    }
  }
}

provider "aws" {
  profile = "private"
  region  = "us-east-1"
}


# ==========================================================================================================================
# variables
# ==========================================================================================================================

variable "project" {
  type = string
}

variable "environment" {
  type = string
}


# ==========================================================================================================================
# modules
# ==========================================================================================================================

# 循環参照にならないように注意

module "route53" {
  source = "../../modules/route53"

  project     = var.project
  environment = var.environment
}

module "acm" {
  source = "../../modules/acm"

  project     = var.project
  environment = var.environment
  domain      = module.route53.domain
}

module "s3" {
  source = "../../modules/s3"

  project     = var.project
  environment = var.environment
}

module "cloudfront" {
  source = "../../modules/cloudfront"

  project                     = var.project
  environment                 = var.environment
  domain                      = module.route53.domain
  route53_zone_id             = module.route53.zone_id
  certificate_arn             = module.acm.certificate_arn
  s3_bucket                   = module.s3.bucket
  origin_access_identity_path = module.s3.origin_access_identity_path
}
