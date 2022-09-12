locals {
  webapp_name                  = (var.webapp_name != "" ? var.webapp_name : module.naming.app_service.name_unique)
  webapp_url                   = "https://${local.webapp_name}.azurewebsites.net"
  functionapp_name             = (var.functionapp_name != "" ? var.functionapp_name : module.naming.function_app.name_unique)
  functionapp_url              = "https://${local.functionapp_name}.azurewebsites.net"
  aad_webapp_name              = (var.aad_webapp_name != "" ? var.aad_webapp_name : "ADS GoFast Web Portal (${var.environment_tag})")
  aad_functionapp_name         = (var.aad_functionapp_name != "" ? var.aad_functionapp_name : "ADS GoFast Orchestration App (${var.environment_tag})")
  purview_name                 = (var.purview_name != "" ? var.purview_name : "${var.prefix}${var.environment_tag}pur${var.app_name}${element(split("-", module.naming.data_factory.name_unique),length(split("-", module.naming.data_factory.name_unique))-1)}")
  purview_account_plink        = (var.purview_name != "" ? var.purview_name : "${var.prefix}-${var.environment_tag}-pura-${lower(var.app_name)}-plink-${element(split("-", module.naming.data_factory.name_unique),length(split("-", module.naming.data_factory.name_unique))-1)}")
  purview_portal_plink        = (var.purview_name != "" ? var.purview_name : "${var.prefix}-${var.environment_tag}-purp-${lower(var.app_name)}-plink-${element(split("-", module.naming.data_factory.name_unique),length(split("-", module.naming.data_factory.name_unique))-1)}")
  purview_resource_group_name  = "managed-${module.naming.resource_group.name_unique}-purview"
  purview_ir_app_reg_name      = (var.purview_ir_app_reg_name != "" ? var.purview_ir_app_reg_name : "ADS GoFast Purview Integration Runtime (${var.environment_tag})") 


  tags = {
    Environment = var.environment_tag
    Owner       = var.owner_tag
    Author      = var.author_tag
    Application = var.app_name
    CreatedDate = timestamp()
  }

}


