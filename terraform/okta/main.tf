#######################
# Working MVP
# See:
# https://developer.okta.com/docs/concepts/oauth-openid/#authorization-code-flow-with-pkce
# https://developer.okta.com/docs/guides/implement-grant-type/-/main/#request-an-authorization-code
#######################

resource "okta_app_oauth" "single_page_app" {
    label                      = local.okta_app_resource_name
    type                       = "browser"
    token_endpoint_auth_method = "none"
    grant_types                = ["authorization_code", "refresh_token"]
    response_types             = ["code"]
    redirect_uris              = ["${var.frontend_website_url}/callback"]
    post_logout_redirect_uris  = [ var.frontend_website_url ]
    login_uri                  = var.frontend_website_url

    lifecycle {
        ignore_changes = [groups]
    }
}

resource "okta_app_group_assignment" "everyone_group_assignment" {
    app_id   = okta_app_oauth.single_page_app.id
    group_id = data.okta_everyone_group.okta_everyone_group.id
}

resource "okta_trusted_origin" "website_origin" {
    name   = local.okta_app_resource_name
    origin = var.frontend_website_url
    scopes = ["REDIRECT"]
}
