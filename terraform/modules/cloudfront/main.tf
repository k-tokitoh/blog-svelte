locals {
  public_domain     = "blog.k-tokitoh.net"
  cloudfront_domain = "blog-svelete-${var.environment}.${var.domain}"
}

resource "aws_cloudfront_distribution" "default" {
  enabled         = true
  is_ipv6_enabled = true
  comment         = "${var.project}-${var.environment}"

  # どの範囲のedge locationを利用するか。
  # - すべてのエッジロケーションを使用する (最高のパフォーマンス)
  # - 北米と欧州のみを使用
  # - 北米、欧州、アジア、中東、アフリカを使用
  price_class = "PriceClass_All"

  # s3のorigin
  origin {
    domain_name = var.s3_bucket.static.reginal_domain_name

    # cloudfront内部でoriginを一意に特定するための文字列
    # ここではbucketのidを利用する
    origin_id = var.s3_bucket.static.id

    origin_access_control_id = aws_cloudfront_origin_access_control.main.id
  }


  default_cache_behavior {
    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    target_origin_id = var.s3_bucket.static.id

    forwarded_values {
      query_string = false
      headers      = []
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"

    # 単位は秒
    # originの値が更新されたら、ただちにキャッシュを破棄する
    min_ttl = 0
    # originがCache-ControlヘッダやExpiresヘッダによりTTLの指定をしていなかった場合に適用される
    # 練習用でデプロイが直ちに反映されてほしいのでゼロで設定する
    default_ttl = 0
    # originがCache-ControlヘッダやExpiresヘッダによりTTLを指定していたとしても、max_ttlが経過したらキャッシュを破棄する
    # 練習用でデプロイが直ちに反映されてほしいのでゼロで設定する
    max_ttl = 0

    # コンテンツ圧縮を有効にする
    compress = true

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.request_handler.arn
    }
  }

  restrictions {
    # 地理的にアクセス元に制限をかけることができる
    geo_restriction {
      restriction_type = "none"
    }
  }

  # どういうドメイン名でのアクセスを受け付けるか
  # route53でcfのドメインに流すだけじゃなくて、受け入れるcfの側でも「どういうドメイン名を起点としたアクセスなら許容する」と指定する必要がある
  aliases = [local.cloudfront_domain, local.public_domain]

  viewer_certificate {
    acm_certificate_arn      = var.certificate_arn
    minimum_protocol_version = "TLSv1.2_2019"

    # 以下があるが、理解はスキップする
    # - sni-only: server name indication（一般に推奨される）
    # - vip: virtual private cloud ip address
    # - static-ip
    ssl_support_method = "sni-only"
  }

  custom_error_response {
    error_caching_min_ttl = 3600
    error_code            = 403
    response_code         = 404
    response_page_path    = "/404/index.html"
  }
}

# policyを付与する交差テーブル的なresource
resource "aws_s3_bucket_policy" "default" {
  bucket = var.s3_bucket.static.bucket
  policy = data.aws_iam_policy_document.static.json
}

data "aws_iam_policy_document" "static" {
  # cloudfrontからのアクセスを許可
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${var.s3_bucket.static.bucket}/*"]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [aws_cloudfront_distribution.default.arn]
    }
  }
}

resource "aws_cloudfront_origin_access_control" "main" {
  name                              = var.s3_bucket.static.bucket
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}


resource "aws_route53_record" "cloudfront" {
  zone_id = var.route53_zone_id
  # レコード名。Aレコードなので「こういうドメインの問い合わせを受けたら...」ということ。
  name = local.cloudfront_domain

  # Aレコードはipアドレス/AWSリソースいずれかを指定できる。ここではAWSリソース = cloudfrontを指定する

  # AレコードでAWSリソースを指定する場合はaliasとしてAWSリソースを指定する（ex. djangoplayground-dev-alb-656552519.us-east-1.elb.amazonaws.com.）
  # route53はs3/elb/cloudfrontなどのAWSリソースに対して「そのドメインのipアドレスはいま何？」と問い合わせる
  # 問い合わせた結果のipアドレスをAレコードとしてDNSサーバからクライアントに返す
  # CNAMEだと、いったんelbのドメイン名をクライアントに返して、クライアントからawsに再びDNS解決を投げなければいけない
  # aliasをつかったAレコードでは通信の回数を抑えることができるのがメリット
  type = "A"
  alias {
    name                   = aws_cloudfront_distribution.default.domain_name
    zone_id                = aws_cloudfront_distribution.default.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "public" {
  zone_id = var.route53_zone_id
  name    = local.public_domain
  type    = "CNAME"
  records = ["blog-svelete-production.${var.domain}"]
  ttl     = 300
}

resource "aws_cloudfront_function" "request_handler" {
  name    = "request_handler"
  runtime = "cloudfront-js-2.0"
  code    = file("${path.module}/src/request-handler.js")
}

//////// キャッシュ削除のlambda関数

resource "aws_iam_role" "create_invalidation" {
  name               = "${var.project}=${var.environment}-create_invalidation"
  assume_role_policy = data.aws_iam_policy_document.assume_create_invalidation.json
}

data "aws_iam_policy_document" "assume_create_invalidation" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      # ユーザーではなくリソースがロールを引き受ける場合は"Service"を指定する
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "create_invalidation" {
  policy_arn = "arn:aws:iam::aws:policy/CloudFrontFullAccess"
  role       = aws_iam_role.create_invalidation.name
}

locals {
  create_invalidation_code = templatefile("${path.module}/src/create-invalidation/main.mjs", {
    cloudfront_distribution_id = aws_cloudfront_distribution.default.id
  })
}

data "archive_file" "create_invalidation" {
  type = "zip"
  source {
    content  = local.create_invalidation_code
    filename = "main.mjs"
  }
  output_path = "${path.module}/src/create-invalidation/main.zip"
}

resource "aws_lambda_function" "create_invalidation" {
  function_name    = "${var.project}-${var.environment}-create_invalidation"
  filename         = data.archive_file.create_invalidation.output_path
  source_code_hash = data.archive_file.create_invalidation.output_base64sha256
  runtime          = "nodejs20.x"
  role             = aws_iam_role.create_invalidation.arn
  # ファイル名がモジュール名になる
  handler = "main.handler"
}

resource "aws_lambda_permission" "create_invalidation" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create_invalidation.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.s3_bucket.static.arn
}

resource "aws_s3_bucket_notification" "create_invalidation" {
  bucket = var.s3_bucket.static.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.create_invalidation.arn
    events              = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
  }
}
