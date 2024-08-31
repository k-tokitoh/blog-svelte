output "bucket" {
  value = {
    static = {
      id                  = aws_s3_bucket.default.id
      reginal_domain_name = aws_s3_bucket.default.bucket_regional_domain_name
    }
  }
}

output "origin_access_identity_path" {
  value = aws_cloudfront_origin_access_identity.default.cloudfront_access_identity_path
}


