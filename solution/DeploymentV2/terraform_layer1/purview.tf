// Create an IR service principal (private linked resources can't use the azure hosted IRs)
resource "azuread_application" "purview_ir" {  
  count        = var.deploy_purview && var.is_vnet_isolated ? 1 : 0
  display_name = local.purview_ir_app_reg_name
  owners       = var.resource_owners
}

resource "azuread_service_principal" "purview_ir" {
  count          = var.deploy_purview && var.is_vnet_isolated ? 1 : 0
  application_id = azuread_application.purview_ir[0].application_id
  owners         = var.resource_owners
}