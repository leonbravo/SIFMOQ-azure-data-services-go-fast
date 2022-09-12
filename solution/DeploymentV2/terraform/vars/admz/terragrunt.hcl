remote_state {
  backend = "azurerm"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    # You need to update the resource group and storage account here. 
    # You should have created these with the Prepare.ps1 script.
    resource_group_name  = "dlzdev08lite"
    storage_account_name = "teststatedev08litestate"
    container_name       = "tstate"
    key                  = "terraform.tfstate"
  }
}

# These inputs are provided to the terraform variables when deploying the environment
# If you are deploying using pipelines, these can be overridden from environment variables
# using TF_VAR_variablename
inputs = {
  prefix                                = "ark"              # All azure resources will be prefixed with this
  domain                                = "arkahna.io"              # Used when configuring AAD config for Azure functions 
  tenant_id                             = "0fee3d31-b963-4a1c-8f4a-ca367205aa65"           # This is the Azure AD tenant ID
  subscription_id                       = "14f299e1-be54-43e9-bf5e-696840f86fc4"     # The azure subscription id to deploy to
  resource_location                     = "Australia East"        # The location of the resources
  resource_group_name                   = "dlzdev08lite"          # The resource group all resources will be deployed to
  owner_tag                             = "Arkahna"               # Owner tag value for Azure resources
  environment_tag                       = "prod"                   # This is used on Azure tags as well as all resource names
  ip_address                            = "101.179.193.89"          # This is the ip address of the agent/current IP. Used to create firewall exemptions.
  deploy_custom_terraform               = false # This is whether the infrastructure located in the terraform_custom folder is deployed or not.  
  configure_networking                  = false
  is_vnet_isolated                      = true
  deploy_web_app                        = false
  deploy_function_app                   = false
  publish_web_app                       = false
  publish_function_app                  = false
  publish_sample_files                  = true
  publish_metadata_database             = false
  publish_datafactory_pipelines         = true
  publish_web_app_addcurrentuserasadmin = true
  deploy_bastion                        = false
  deploy_sentinel                       = false
  deploy_purview                        = false  
  deploy_synapse                        = true  
  deploy_app_service_plan               = false
  deploy_synapse_sqlpool                = false
  deploy_selfhostedsql                  = false
  deploy_h2o-ai                         = false
  deploy_metadata_database              = false
  is_onprem_datafactory_ir_registered   = false

  #Below is a space for providing details of EXISTING resources so that the deployment can integrate with your management zone.
  #Please ensure that you enter everything that is relevant otherwise deployed resources may not work properly.
  #log anayltics resource id can be found under the properties of the log analytics resource NOTE: This is the full URI not the workspaceID
  #workspace id can be found under the main page, it is a guid
  existing_log_analytics_resource_id   = "/subscriptions/14f299e1-be54-43e9-bf5e-696840f86fc4/resourceGroups/dlzdev08lite/providers/Microsoft.OperationalInsights/workspaces/ark-stg-log-ads-g4js"
  existing_log_analytics_workspace_id   = "23bfd865-7b4e-494c-8538-a872f54c3893"
  #synapse private link hub id can be found under the properties of the synapse private link NOTE: This is the full URI (ResourceID)
  existing_synapse_private_link_hub_id  = "/subscriptions/14f299e1-be54-43e9-bf5e-696840f86fc4/resourceGroups/dlzdev08lite/providers/Microsoft.Synapse/privateLinkHubs/arkstgsynwadsg4jsplink"
  #Please assign subnet id's for the following - you may end up using the same subnet id for all of these resources depending on your already deployed assets.
  #command used to get subnet ids:
  # az network vnet subnet show -g MyResourceGroup -n MySubnet --vnet-name MyVNet
  existing_plink_subnet_id              = "/subscriptions/14f299e1-be54-43e9-bf5e-696840f86fc4/resourceGroups/dlzdev08lite/providers/Microsoft.Network/virtualNetworks/ark-stg-vnet-ads/subnets/ark-stg-snet-ads-plink"
  existing_bastion_subnet_id            = "/subscriptions/14f299e1-be54-43e9-bf5e-696840f86fc4/resourceGroups/dlzdev08lite/providers/Microsoft.Network/virtualNetworks/ark-stg-vnet-ads/subnets/AzureBastionSubnet"
  existing_app_service_subnet_id        = "/subscriptions/14f299e1-be54-43e9-bf5e-696840f86fc4/resourceGroups/dlzdev08lite/providers/Microsoft.Network/virtualNetworks/ark-stg-vnet-ads/subnets/ark-stg-snet-ads-appservice"
  existing_vm_subnet_id                 = "/subscriptions/14f299e1-be54-43e9-bf5e-696840f86fc4/resourceGroups/dlzdev08lite/providers/Microsoft.Network/virtualNetworks/ark-stg-vnet-ads/subnets/ark-stg-snet-ads-vm"

  #assign the private DNS zone id's for the following.
  #command used to get existing private-dns zones:
  #az network private-dns zone list -g MyResourceGroup
  existing_private_dns_zone_db_id       = "/subscriptions/14f299e1-be54-43e9-bf5e-696840f86fc4/resourceGroups/dlzdev08lite/providers/Microsoft.Network/privateDnsZones/privatelink.database.windows.net"
  existing_private_dns_zone_kv_id       = "/subscriptions/14f299e1-be54-43e9-bf5e-696840f86fc4/resourceGroups/dlzdev08lite/providers/Microsoft.Network/privateDnsZones/privatelink.vaultcore.azure.net"
  existing_private_dns_zone_blob_id     = "/subscriptions/14f299e1-be54-43e9-bf5e-696840f86fc4/resourceGroups/dlzdev08lite/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net"
  existing_private_dns_zone_queue_id    = "/subscriptions/14f299e1-be54-43e9-bf5e-696840f86fc4/resourceGroups/dlzdev08lite/providers/Microsoft.Network/privateDnsZones/privatelink.queue.core.windows.net"
  existing_private_dns_zone_dfs_id      = "/subscriptions/14f299e1-be54-43e9-bf5e-696840f86fc4/resourceGroups/dlzdev08lite/providers/Microsoft.Network/privateDnsZones/privatelink.dfs.core.windows.net"
  existing_private_dns_zone_purview_id  = "/subscriptions/14f299e1-be54-43e9-bf5e-696840f86fc4/resourceGroups/dlzdev08lite/providers/Microsoft.Network/privateDnsZones/privatelink.purview.azure.com"
  existing_private_dns_zone_purview_studio_id = "/subscriptions/14f299e1-be54-43e9-bf5e-696840f86fc4/resourceGroups/dlzdev08lite/providers/Microsoft.Network/privateDnsZones/privatelink.purviewstudio.azure.com"
  existing_private_dns_zone_servicebus_id = "/subscriptions/14f299e1-be54-43e9-bf5e-696840f86fc4/resourceGroups/dlzdev08lite/providers/Microsoft.Network/privateDnsZones/privatelink.servicebus.windows.net"
  existing_private_dns_zone_synapse_gateway_id = "/subscriptions/14f299e1-be54-43e9-bf5e-696840f86fc4/resourceGroups/dlzdev08lite/providers/Microsoft.Network/privateDnsZones/privatelink.azuresynapse.net"
  existing_private_dns_zone_synapse_studio_id = "/subscriptions/14f299e1-be54-43e9-bf5e-696840f86fc4/resourceGroups/dlzdev08lite/providers/Microsoft.Network/privateDnsZones/privatelink.dev.azuresynapse.net"
  existing_private_dns_zone_synapse_sql_id = "/subscriptions/14f299e1-be54-43e9-bf5e-696840f86fc4/resourceGroups/dlzdev08lite/providers/Microsoft.Network/privateDnsZones/privatelink.sql.azuresynapse.net"

} 
