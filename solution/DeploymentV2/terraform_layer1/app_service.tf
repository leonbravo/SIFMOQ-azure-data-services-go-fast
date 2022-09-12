
resource "random_uuid" "app_reg_role_id" {}
resource "random_uuid" "app_reg_role_id2" {}

resource "azuread_application" "web_reg" {
  count        = var.deploy_web_app && var.deploy_azure_ad_web_app_registration ? 1 : 0
  display_name = local.aad_webapp_name
  owners       = [data.azurerm_client_config.current.object_id]
  web {
    homepage_url  = local.webapp_url
    redirect_uris = ["${local.webapp_url}/signin-oidc", "https://localhost:44385/signin-oidc"]
    implicit_grant {
      access_token_issuance_enabled = false
      id_token_issuance_enabled     = true
    }
  }
  app_role {
    allowed_member_types = ["User"]
    id                   = random_uuid.app_reg_role_id.result
    description          = "Administer features of the application"
    display_name         = "Administrator"
    enabled              = true
    value                = "Administrator"
  }

  app_role {
    allowed_member_types = ["User"]
    id                   = random_uuid.app_reg_role_id2.result
    description          = "Reader features of the application"
    display_name         = "Reader"
    enabled              = true
    value                = "Reader"
  }

  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000"

    resource_access {
      id   = "b340eb25-3456-403f-be2f-af7a0d370277"
      type = "Scope"
    }
    resource_access {
      id   = "37f7f235-527c-4136-accd-4a02d197296e"
      type = "Scope"
    }
    resource_access {
      id   = "14dad69e-099b-42c9-810b-d002981feec1"
      type = "Scope"
    }
    resource_access {
      id   = "7ab1d382-f21e-4acd-a863-ba3e13f7da61"
      type = "Role"
    }
    resource_access {
      id   = "98830695-27a2-44f7-8c18-0c3ebc9698f6"
      type = "Role"
    }
  }
}

resource "time_sleep" "wait_30_seconds" {
  depends_on      = [azuread_application.web_reg]
  create_duration = "30s"
}

resource "azuread_service_principal" "web_sp" {
  count          = var.deploy_web_app && var.deploy_azure_ad_web_app_registration ? 1 : 0
  application_id = azuread_application.web_reg[0].application_id
  owners         = [data.azurerm_client_config.current.object_id]
  depends_on     = [time_sleep.wait_30_seconds]
}



