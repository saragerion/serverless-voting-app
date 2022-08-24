resource "okta_app_oauth" "single_page_app" {
    label                      = local.okta_app_resource_name
    type                       = "browser"
    grant_types                = ["authorization_code", "implicit"]
    redirect_uris              = ["${var.frontend_website_url}/callback"]
    post_logout_redirect_uris  = [ var.frontend_website_url ]
    response_types             = ["token", "id_token", "code"]

    login_uri = "${var.frontend_website_url}/"

    token_endpoint_auth_method  = "none"

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
    scopes = ["CORS", "REDIRECT"]
}
