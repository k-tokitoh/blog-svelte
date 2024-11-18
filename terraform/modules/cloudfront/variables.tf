variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "domain" {
  type = string
}

variable "route53_zone_id" {
  type = string
}

variable "certificate_arn" {
  type = string
}

variable "s3_bucket" {
  type = object({
    static = object({
      id                  = string
      bucket              = string
      reginal_domain_name = string
      arn                 = string
    })
  })
}

