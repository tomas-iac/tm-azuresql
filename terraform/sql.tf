// SQL Server
resource "azurerm_mssql_server" "sql" {
  name                         = var.serverName
  resource_group_name          = var.resourceGroupName
  location                     = var.location
  version                      = "12.0"
  administrator_login          = var.adminUsername
  administrator_login_password = var.adminPassword

}

// SQL DB
resource "azurerm_mssql_database" "test" {
  name           = var.dbName
  server_id      = azurerm_mssql_server.sql.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "BasePrice"
  max_size_gb    = 4
  read_scale     = false
  sku_name       = var.sku
  zone_redundant = false
}

// Private Endpoint
resource "azurerm_private_endpoint" "sql" {
  name                = "${var.dbName}-private-endpoint"
  resource_group_name = var.resourceGroupName
  location            = var.location
  subnet_id           = var.subnetId

  private_dns_zone_group {
    name = "${var.dbName}-dns"

    private_dns_zone_ids = [
      var.privateDnsZoneId
    ]
  }

  private_service_connection {
    name                           = "${var.dbName}-sql"
    private_connection_resource_id = azurerm_mssql_server.sql.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }
}

// Audit logs
resource "azurerm_monitor_diagnostic_setting" "sql" {
  count                      = var.enableMonitoring ? 1 : 0
  name                       = "${var.dbName}-sql-audit"
  target_resource_id         = "${azurerm_mssql_server.sql.id}/databases/master"
  log_analytics_workspace_id = var.logAnalyticsWorkspaceId

  log {
    category = "SQLSecurityAuditEvents"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = false

    retention_policy {
      enabled = false
    }
  }

  lifecycle {
    ignore_changes = [log, metric]
  }
}

resource "azurerm_mssql_database_extended_auditing_policy" "sql" {
  count                  = var.enableMonitoring ? 1 : 0
  database_id            = "${azurerm_mssql_server.sql.id}/databases/master"
  log_monitoring_enabled = true
}

resource "azurerm_mssql_server_extended_auditing_policy" "sql" {
  count                  = var.enableMonitoring ? 1 : 0
  server_id              = azurerm_mssql_server.sql.id
  log_monitoring_enabled = true
}

// ZMENA
