resource "azurerm_data_factory" "data_factory" {
  count                           = var.deploy_data_factory ? 1 : 0
  name                            = local.data_factory_name
  location                        = var.resource_location
  resource_group_name             = var.resource_group_name
  public_network_enabled          = var.is_vnet_isolated == false || var.delay_private_access
  managed_virtual_network_enabled = true
  dynamic "github_configuration" {
    for_each = ((var.adf_git_toggle_integration) ? [true] : [])
    content {
      account_name    = var.adf_git_repository_owner
      branch_name     = var.adf_git_repository_branch_name
      repository_name = var.adf_git_repository_name
      root_folder     = var.adf_git_repository_root_folder
      git_url         = var.adf_git_host_url
    }
  }


  identity {
    type = "SystemAssigned"
  }
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_role_assignment" "datafactory_function_app" {
  count                = var.deploy_data_factory && var.deploy_function_app ? 1 : 0
  scope                = azurerm_data_factory.data_factory[0].id
  role_definition_name = "Contributor"
  principal_id         = azurerm_function_app.function_app[0].identity[0].principal_id
}


# // Diagnostic logs--------------------------------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "data_factory_diagnostic_logs" {
  count = var.deploy_data_factory ? 1 : 0
  name  = "diagnosticlogs"
  # ignore_changes is here given the bug  https://github.com/terraform-providers/terraform-provider-azurerm/issues/10388
  lifecycle {
    ignore_changes = [log, metric]
  }
  target_resource_id             = azurerm_data_factory.data_factory[0].id
  log_analytics_workspace_id     = local.log_analytics_resource_id
  log_analytics_destination_type = "Dedicated"

  log {
    category = "ActivityRuns"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = true
    }
  }
  log {
    category = "PipelineRuns"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = true
    }
  }
  log {
    category = "TriggerRuns"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = true
    }
  }
  log {
    category = "SSISIntegrationRuntimeLogs"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = true
    }
  }
  log {
    category = "SandboxPipelineRuns"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = true
    }
  }
  log {
    category = "SandboxActivityRuns"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = true
    }
  }
  log {
    category = "SSISPackageExecutionDataStatistics"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = true
    }
  }
  log {
    category = "SSISPackageExecutionComponentPhases"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = true
    }
  }
  log {
    category = "SSISPackageExecutableStatistics"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = true
    }
  }
  log {
    category = "SSISPackageEventMessages"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = true
    }
  }
  log {
    category = "SSISPackageEventMessageContext"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = true
    }
  }
  log {
    category = "SSISIntegrationRuntimeLogs"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = true
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = true
    retention_policy {
      days    = 0
      enabled = true
    }
  }
}

