data "aws_acm_certificate" "existing" {
  domain = "*.${var.domain}"
}
