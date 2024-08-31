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

module "s3" {
  source = "../../modules/s3"

  project     = var.project
  environment = var.environment
}
