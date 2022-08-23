resource "okta_app_oauth" "example" {
    label                      = local.okta_app_resource_name
    type                       = "browser"
    grant_types                = ["authorization_code", "implicit"]
    redirect_uris              = ["${var.website_redirect_url_domain}/callback"]
    post_logout_redirect_uris  = [ var.website_redirect_url_domain ]
    response_types             = ["token", "id_token", "code"]

    login_uri = "${var.website_redirect_url_domain}/"

}
