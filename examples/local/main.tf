
resource "azurerm_resource_group" "test" {
  name     = "unit-test-sql-rg"
  location = "eastus2"
}

resource "azurerm_virtual_network" "test" {
  name                = "test-vnet"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "test" {
  name                                           = "test-subnet"
  resource_group_name                            = azurerm_resource_group.test.name
  virtual_network_name                           = azurerm_virtual_network.test.name
  address_prefixes                               = ["10.0.0.0/20"]
  enforce_private_link_endpoint_network_policies = true
}

// DNS zone
resource "azurerm_private_dns_zone" "privateendpoints" {
  name                = "privatelink.database.windows.net"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "test" {
  name                  = "test"
  resource_group_name   = azurerm_resource_group.test.name
  private_dns_zone_name = azurerm_private_dns_zone.privateendpoints.name
  virtual_network_id    = azurerm_virtual_network.test.id
}

// Monitoring
resource "azurerm_log_analytics_workspace" "test" {
  name                = "test-kjahsdfkjhd37454382"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

// Module testing (local reference)
module "azuresql" {
  source                  = "../../terraform"
  serverName              = "project1-sql-dfkusfvj34324"
  dbName                  = "mydb"
  location                = azurerm_resource_group.test.location
  resourceGroupName       = azurerm_resource_group.test.name
  subnetId                = azurerm_subnet.test.id
  privateDnsZoneId        = azurerm_private_dns_zone.privateendpoints.id
  adminUsername           = "tomas"
  adminPassword           = "Azure12345678"
  logAnalyticsWorkspaceId = azurerm_log_analytics_workspace.test.id
  enableMonitoring        = true
}

