locals {
  github_org         = element(split("/", var.github_repo), 0)
  github_repo        = element(split("/", var.github_repo), 1)
  role_resource_name = "${local.github_org}-${local.github_repo}-github-oidc-role"
}
