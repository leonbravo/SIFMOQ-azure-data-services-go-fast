// Allows purview to retrieve the IR service principal password
resource "azurerm_key_vault_access_policy" "purview_access" {
  count        = var.deploy_purview ? 1 : 0
  key_vault_id = data.terraform_remote_state.layer2.outputs.azurerm_key_vault_app_vault_id
  tenant_id    = var.tenant_id
  object_id    = data.terraform_remote_state.layer2.outputs.purview_account_principal_id


  key_permissions = [
    "Get", "List"
  ]

  secret_permissions = [
    "List", "Get"
  ]
  depends_on = []
}

resource "azurerm_key_vault_secret" "purview_ir_sp_password" {
  count        = var.deploy_purview && var.is_vnet_isolated ? 1 : 0
  name         = "AzurePurviewIr"
  value        = azuread_application_password.purview_ir[0].value
  key_vault_id = data.terraform_remote_state.layer2.outputs.azurerm_key_vault_app_vault_id
  depends_on = [  ]
}

resource "azurerm_key_vault_secret" "azure_function_secret" {
  count        = var.deploy_function_app ? 1 : 0
  name         = "AzureFunctionClientSecret"
  value        = azuread_application_password.function_app[0].value
  key_vault_id = data.terraform_remote_state.layer2.outputs.azurerm_key_vault_app_vault_id
}



