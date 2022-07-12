inputs = {
  prefix                               = "bce"              # All azure resources will be prefixed with this
  domain                                = "microsoft.com"              # Used when configuring AAD config for Azure functions 
  tenant_id                             = "378620f7-aa4a-40ac-902a-2ef913d8ed69"           # This is the Azure AD tenant ID
  subscription_id                       = "21fec1ab-7af8-4f99-b66f-a69e7ba77a22"     # The azure subscription id to deploy to
  resource_location                     = "Australia East"        # The location of the resources
  resource_group_name                   = "bce-aae-oea-dev-syn"          # The resource group all resources will be deployed to
  owner_tag                             = "bce"               # Owner tag value for Azure resources
  environment_tag                       = "dev"                   # This is used on Azure tags as well as all resource names
  ip_address                            = "103.12.191.19"          # This is the ip address of the agent/current IP. Used to create firewall exemptions.
  deploy_web_app                        = true
  deploy_function_app                   = true
  deploy_custom_terraform               = true # This is whether the infrastructure located in the terraform_custom folder is deployed or not.
  deploy_app_service_plan               = true
  deploy_data_factory                   = false
  deploy_sentinel                       = false
  deploy_purview                        = false
  deploy_synapse                        = true
  deploy_metadata_database              = true
  is_vnet_isolated                      = false
  publish_web_app                       = true
  publish_function_app                  = true
  publish_sample_files                  = true
  publish_sif_database                  = true
  publish_metadata_database             = true
  configure_networking                  = true
  publish_datafactory_pipelines         = true
  publish_web_app_addcurrentuserasadmin = true
  deploy_selfhostedsql                  = true
  is_onprem_datafactory_ir_registered   = true
}
