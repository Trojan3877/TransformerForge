###############################################################################
#  GitHub-Actions OIDC  ➜  AWS  (key-less deploy)
###############################################################################

data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_role" "gha_deploy" {
  name = "tf-gha-eks-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = data.aws_iam_openid_connect_provider.github.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:sub" = "repo:Trojan3877/TransformerForge:*"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "gha_admin" {
  role       = aws_iam_role.gha_deploy.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

output "gha_role_arn" { value = aws_iam_role.gha_deploy.arn }
