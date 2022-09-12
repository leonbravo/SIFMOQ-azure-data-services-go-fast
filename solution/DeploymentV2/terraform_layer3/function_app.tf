# This allows the function app MSI to be able to call/request the Azure function App reg
resource "azuread_app_role_assignment" "func_msi_app_role" {
  count               = var.deploy_function_app && var.deploy_azure_ad_function_app_registration ? 1 : 0
  app_role_id         = data.terraform_remote_state.layer2.outputs.random_uuid_function_app_reg_role_id
  principal_object_id = data.terraform_remote_state.layer2.outputs.azurerm_function_app_identity_principal_id
  resource_object_id  = data.terraform_remote_state.layer2.outputs.azuread_service_principal_function_app_object_id
}

# This allows the function app SP to be able to call/request the Azure function App reg / SP
# This allows us to debug locally by using the app reg details for both auth modes
resource "azuread_app_role_assignment" "func_sp_app_role" {
  count               = var.deploy_function_app && var.deploy_azure_ad_function_app_registration ? 1 : 0
  app_role_id         = data.terraform_remote_state.layer2.outputs.random_uuid_function_app_reg_role_id
  principal_object_id = data.terraform_remote_state.layer2.outputs.azuread_service_principal_function_app_object_id
  resource_object_id  = data.terraform_remote_state.layer2.outputs.azuread_service_principal_function_app_object_id
}

resource "azuread_application_password" "function_app" {
  count                 = var.deploy_function_app && var.deploy_azure_ad_function_app_registration ? 1 : 0
  application_object_id = data.terraform_remote_state.layer2.outputs.azuread_application_function_app_reg_object_id
}


