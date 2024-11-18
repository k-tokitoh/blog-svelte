output "bucket" {
  value = {
    static = {
      id                  = aws_s3_bucket.default.id
      bucket              = aws_s3_bucket.default.bucket
      reginal_domain_name = aws_s3_bucket.default.bucket_regional_domain_name
    }
  }
}



