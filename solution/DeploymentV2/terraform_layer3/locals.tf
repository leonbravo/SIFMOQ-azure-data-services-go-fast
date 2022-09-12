locals {
  webapp_name                  = (var.webapp_name != "" ? var.webapp_name : module.naming.app_service.name_unique)
  webapp_url                   = "https://${local.webapp_name}.azurewebsites.net"
  functionapp_name             = (var.functionapp_name != "" ? var.functionapp_name : module.naming.function_app.name_unique)
  functionapp_url              = "https://${local.functionapp_name}.azurewebsites.net"
  aad_webapp_name              = (var.aad_webapp_name != "" ? var.aad_webapp_name : "ADS GoFast Web Portal (${var.environment_tag})")
  aad_functionapp_name         = (var.aad_functionapp_name != "" ? var.aad_functionapp_name : "ADS GoFast Orchestration App (${var.environment_tag})")
  purview_name                 = data.terraform_remote_state.layer2.outputs.purview_name
  purview_account_plink        = "${var.prefix}-${var.environment_tag}-pura-${lower(var.app_name)}-plink-${element(split("-", module.naming.data_factory.name_unique),length(split("-", module.naming.data_factory.name_unique))-1)}"
  purview_portal_plink         = "${var.prefix}-${var.environment_tag}-purp-${lower(var.app_name)}-plink-${element(split("-", module.naming.data_factory.name_unique),length(split("-", module.naming.data_factory.name_unique))-1)}"
  purview_resource_group_name  = "managed-${module.naming.resource_group.name_unique}-purview"
  purview_ir_app_reg_name      = data.terraform_remote_state.layer2.outputs.purview_sp_name
  private_dns_zone_servicebus_id = data.terraform_remote_state.layer2.outputs.private_dns_zone_servicebus_id
  private_dns_zone_queue_id = data.terraform_remote_state.layer2.outputs.private_dns_zone_queue_id
  private_dns_zone_blob_id      = data.terraform_remote_state.layer2.outputs.private_dns_zone_blob_id
  private_dns_zone_purview_id      = data.terraform_remote_state.layer2.outputs.private_dns_zone_purview_id
  private_dns_zone_purview_studio_id      = data.terraform_remote_state.layer2.outputs.private_dns_zone_purview_studio_id
  plink_subnet_id              = data.terraform_remote_state.layer2.outputs.plink_subnet_id

  tags = {
    Environment = var.environment_tag
    Owner       = var.owner_tag
    Author      = var.author_tag
    Application = var.app_name
    CreatedDate = timestamp()
  }

}


