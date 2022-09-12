resource "azuread_application_password" "purview_ir" {
  count                 = var.deploy_purview && var.is_vnet_isolated ? 1 : 0
  application_object_id = data.terraform_remote_state.layer2.outputs.azuread_application_purview_ir_object_id
}

resource "azurerm_private_endpoint" "purview_account_private_endpoint_with_dns" {
  count               = var.is_vnet_isolated && var.deploy_purview ? 1 : 0
  name                = local.purview_account_plink
  location            = var.resource_location
  resource_group_name = var.resource_group_name
  subnet_id           = local.plink_subnet_id

  private_service_connection {
    name                           = "${local.purview_account_plink}-conn"
    private_connection_resource_id = data.terraform_remote_state.layer2.outputs.azurerm_purview_account_purview_id
    is_manual_connection           = false
    subresource_names              = ["account"]
  }

  private_dns_zone_group {
    name                 = "privatednszonegroup"
    private_dns_zone_ids = [local.private_dns_zone_purview_id]
  }

  depends_on = [
  ]

  tags = local.tags
  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_private_endpoint" "purview_portal_private_endpoint_with_dns" {
  count               = var.is_vnet_isolated && var.deploy_purview ? 1 : 0
  name                = local.purview_portal_plink
  location            = var.resource_location
  resource_group_name = var.resource_group_name
  subnet_id           = local.plink_subnet_id

  private_service_connection {
    name                           = "${local.purview_portal_plink}-conn"
    private_connection_resource_id = data.terraform_remote_state.layer2.outputs.azurerm_purview_account_purview_id
    is_manual_connection           = false
    subresource_names              = ["portal"]
  }

  private_dns_zone_group {
    name                 = "privatednszonegroup"
    private_dns_zone_ids = [local.private_dns_zone_purview_studio_id]
  }

  depends_on = [   
  ]

  tags = local.tags
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

# Azure private endpoints
module "purview_ingestion_private_endpoints" {
  source                      = "./modules/purview_ingestion_private_endpoints"
  count                       = var.is_vnet_isolated && var.deploy_purview ? 1 : 0
  resource_group_name         = var.resource_group_name
  purview_account_name        = data.terraform_remote_state.layer2.outputs.purview_name
  resource_location           = var.resource_location
  queue_privatelink_name      = "${local.purview_name}-queue-plink"
  storage_privatelink_name    = "${local.purview_name}-storage-plink"
  eventhub_privatelink_name   = "${local.purview_name}-event-plink"
  blob_private_dns_id         = local.private_dns_zone_blob_id
  queue_private_dns_id        = local.private_dns_zone_queue_id
  servicebus_private_dns_id   = local.private_dns_zone_servicebus_id
  subnet_id                   = local.plink_subnet_id
  managed_resource_group_name = local.purview_resource_group_name
  name_suffix                 = random_id.rg_deployment_unique.id
  subscription_id             = var.subscription_id

  depends_on = [
    azurerm_private_endpoint.purview_account_private_endpoint_with_dns,azurerm_private_endpoint.purview_portal_private_endpoint_with_dns
  ]
}
