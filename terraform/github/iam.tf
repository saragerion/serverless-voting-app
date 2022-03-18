resource "aws_iam_openid_connect_provider" "github_oidc_provider" {
    url = "https://token.actions.githubusercontent.com"

    client_id_list = [
        "sts.amazonaws.com"
    ]

    thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

data "aws_iam_policy_document" "github_oidc_provider_policy" {
    statement {
        effect  = "Allow"
        actions = ["sts:AssumeRoleWithWebIdentity"]

        principals {
            type        = "Federated"
            identifiers = [aws_iam_openid_connect_provider.github_oidc_provider.arn]
        }

        condition {
            test     = "StringLike"
            variable = "token.actions.githubusercontent.com:sub"
            values   = ["repo:${var.github_repo}:*"]
        }
    }
}

data "aws_iam_policy" "github_oidc_provider_policy_read_only" {
    arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "github_oidc_provider_policy_read_only_attachment" {
    role       = aws_iam_role.github_oidc_provider.name
    policy_arn = data.aws_iam_policy.github_oidc_provider_policy_read_only.arn
}

resource "aws_iam_role" "github_oidc_provider" {
    name               = local.role_resource_name
    assume_role_policy = data.aws_iam_policy_document.github_oidc_provider_policy.json
}
