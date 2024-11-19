# idpの登録は複数のrepoから共有するのでdataとする
data "aws_iam_openid_connect_provider" "github" {
  arn = "arn:aws:iam::470855045134:oidc-provider/token.actions.githubusercontent.com"
}

# githubのsecretsにroleのarnを登録する必要がある
# （blog-svelteはそうではないが）インフラ費用がかかる場合は terraform destroy/apply により環境の作成と破棄を低コストで行いたい
# この iam role を terraform apply で作成する形にすると、都度 github の secrets を更新する必要が生じる
# その手間を回避するため role は手動で作成し、data で存在を担保する形とする
data "aws_iam_role" "deploy" {
  name = "blog-svelte-deploy"
}

#### resource で作成する場合は以下

# resource "aws_iam_role" "deploy" {
#   name               = "${var.project}-deploy"
#   assume_role_policy = data.aws_iam_policy_document.assume_deploy.json
# }

# data "aws_iam_policy_document" "assume_deploy" {
#   statement {
#     actions = ["sts:AssumeRoleWithWebIdentity"]

#     principals {
#       type        = "Federated"
#       identifiers = [data.aws_iam_openid_connect_provider.github.arn]
#     }

#     condition {
#       test     = "StringEquals"
#       variable = "token.actions.githubusercontent.com:aud"
#       values   = ["sts.amazonaws.com"]
#     }

#     condition {
#       test     = "StringLike"
#       variable = "token.actions.githubusercontent.com:sub"
#       values   = ["repo:k-tokitoh/blog-svelte:*"]
#     }
#   }
# }

# resource "aws_iam_role_policy_attachment" "deploy__s3_full_access" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
#   role       = aws_iam_role.deploy.name
# }

# resource "aws_iam_role_policy_attachment" "deploy__lambda_full_access" {
#   policy_arn = "arn:aws:iam::aws:policy/AWSLambda_FullAccess"
#   role       = aws_iam_role.deploy.name
# }
