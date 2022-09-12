resource "azurerm_purview_account" "purview" {
  count                       = var.deploy_purview ? 1 : 0
  name                        = local.purview_name
  resource_group_name         = var.resource_group_name
  location                    = var.purview_resource_location == "" ? var.resource_location : var.purview_resource_location
  managed_resource_group_name = local.purview_resource_group_name
  public_network_enabled      = var.is_vnet_isolated == false || var.delay_private_access
  tags                        = local.tags

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}



