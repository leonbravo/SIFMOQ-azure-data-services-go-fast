# Azure Integration runtime
resource "azurerm_data_factory_integration_runtime_azure" "azure_ir" {
  for_each = {
    for ir in local.integration_runtimes :
    ir.short_name => ir
    if ir.is_azure && var.deploy_data_factory == true
  }
  name                    = each.value.name
  data_factory_id         = azurerm_data_factory.data_factory[0].id
  location                = var.resource_location
  #resource_group_name     = var.resource_group_name
  time_to_live_min        = 10
  virtual_network_enabled = var.is_vnet_isolated && each.value.is_managed_vnet
  depends_on = [
    azurerm_data_factory.data_factory
  ]
}

resource "azurerm_data_factory_integration_runtime_self_hosted" "self_hosted_ir" {
  for_each = {
    for ir in local.integration_runtimes :
    ir.short_name => ir
    if ir.is_azure == false && var.deploy_data_factory == true
  }
  name                = each.value.name
  data_factory_id     = azurerm_data_factory.data_factory[0].id
  #resource_group_name = var.resource_group_name
  depends_on = [
    azurerm_data_factory.data_factory
  ]
} 