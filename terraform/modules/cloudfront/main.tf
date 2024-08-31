locals {
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

    s3_origin_config {
      origin_access_identity = var.origin_access_identity_path
    }
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
  }

  restrictions {
    # 地理的にアクセス元に制限をかけることができる
    geo_restriction {
      restriction_type = "none"
    }
  }

  # どういうドメイン名でのアクセスを受け付けるか
  # route53でcfのドメインに流すだけじゃなくて、受け入れるcfの側でも「どういうドメイン名を起点としたアクセスなら許容する」と指定する必要がある
  aliases = [local.cloudfront_domain]

  viewer_certificate {
    acm_certificate_arn      = var.certificate_arn
    minimum_protocol_version = "TLSv1.2_2019"

    # 以下があるが、理解はスキップする
    # - sni-only: server name indication（一般に推奨される）
    # - vip: virtual private cloud ip address
    # - static-ip
    ssl_support_method = "sni-only"
  }
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
