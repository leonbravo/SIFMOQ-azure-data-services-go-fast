
resource "azurerm_app_service" "web" {
  count               = var.deploy_app_service_plan && var.deploy_web_app ? 1 : 0
  name                = local.webapp_name
  location            = var.resource_location
  resource_group_name = var.resource_group_name
  app_service_plan_id = azurerm_app_service_plan.app_service_plan[0].id
  https_only          = true
  client_cert_enabled = false
  app_settings = {
    WEBSITE_RUN_FROM_PACKAGE = 1

    ApplicationOptions__UseMSI                              = true
    ApplicationOptions__AdsGoFastTaskMetaDataDatabaseServer = var.deploy_metadata_database ? "${azurerm_mssql_server.sqlserver[0].name}.database.windows.net" : null
    ApplicationOptions__AdsGoFastTaskMetaDataDatabaseName   = var.deploy_metadata_database ? azurerm_mssql_database.web_db[0].name : null

    ApplicationOptions__AppInsightsWorkspaceId  = azurerm_application_insights.app_insights[0].app_id
    ApplicationOptions__LogAnalyticsWorkspaceId = local.log_analytics_resource_id

    SecurityModelOptions__SecurityRoles__Administrator__SecurityGroupId = var.web_app_admin_security_group

    AzureAdAuth__Domain   = var.domain
    AzureAdAuth__TenantId = var.tenant_id
    AzureAdAuth__ClientId = data.terraform_remote_state.layer1.outputs.aad_webreg_id 
  }

  site_config {
    always_on                = true
    dotnet_framework_version = "v6.0"
    min_tls_version          = "1.2"
    ftps_state               = "Disabled"
    http2_enabled            = true
    vnet_route_all_enabled   = var.is_vnet_isolated
  }
  auth_settings {
    enabled = false
  }

  identity {
    type = "SystemAssigned"
  }

  tags = local.tags
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_app_service_virtual_network_swift_connection" "vnet_integration" {
  count          = var.is_vnet_isolated && var.deploy_web_app ? 1 : 0
  app_service_id = azurerm_app_service.web[0].id
  subnet_id      = local.app_service_subnet_id
}


# // Diagnostic logs--------------------------------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "app_service_diagnostic_logs" {
  name                       = "diagnosticlogs"
  count                      = var.deploy_web_app ? 1 : 0
  target_resource_id         = azurerm_app_service.web[0].id
  log_analytics_workspace_id = local.log_analytics_resource_id
  # ignore_changes is here given the bug  https://github.com/terraform-providers/terraform-provider-azurerm/issues/10388
  lifecycle {
    ignore_changes = [log, metric]
  }
  log {
    category = "AppServiceHTTPLogs"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = true
    }
  }
  log {
    category = "AppServiceHTTPLogs"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = true
    }
  }
  log {
    category = "AppServiceConsoleLogs"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = true
    }
  }
  log {
    category = "AppServiceAppLogs"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = true
    }
  }
  log {
    category = "AppServiceAuditLogs"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = true
    }
  }
  log {
    category = "AppServiceIPSecAuditLogs"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = true
    }
  }
  log {
    category = "AppServicePlatformLogs"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = true
    }
  }
  metric {
    category = "AllMetrics"
    enabled  = false
    retention_policy {
      days    = 0
      enabled = true
    }
  }
}

