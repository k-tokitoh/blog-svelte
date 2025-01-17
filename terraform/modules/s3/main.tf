# ==========================================================================================================================
# static bucket
# ==========================================================================================================================

# 配信したい静的なファイルを配置する、privateなバケット
resource "aws_s3_bucket" "default" {
  # バケット名
  # ユニークにするために末尾にランダムな数字の文字列を付加する
  bucket = "${lower(var.project)}-${lower(var.environment)}-39874962"

  # force_destroy = true にすると、バケットを削除する際に中身があっても削除できる
  # 練習用なので、CIによりデプロイされたファイルが入っていてもterraform destroyで削除できてほしいのでtrueにする
  force_destroy = true
}

# 以下で「静的ウェブサイトホスティング」ができる（今回はしない）
# resource "aws_s3_bucket_website_configuration" "default" {
#   bucket = aws_s3_bucket.default.bucket
#   index_document {
#     suffix = "index.html"
#   }
# }
#
resource "aws_s3_bucket_public_access_block" "default" {
  bucket = aws_s3_bucket.default.bucket

  # 「パブリックアクセスOKだよ」というACLの追加をブロックする
  block_public_acls = true

  # 「パブリックアクセスOKだよ」というACLが元から存在していた場合、その許可を無視する（パブリックアクセスを禁じる）
  ignore_public_acls = true

  # 「パブリックアクセスOKだよ」というpolicyの追加をブロックする
  block_public_policy = true

  # 「パブリックアクセスOKだよ」というpolicyが元から存在していた場合、その許可を無視する（パブリックアクセスを禁じる）
  restrict_public_buckets = true
}
