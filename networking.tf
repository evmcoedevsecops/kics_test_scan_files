terraform {
  backend "remote" {
    organization = "caliber"

    workspaces {
      name = "Test2"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "acceptanceTestResourceGroup1"
  location = "West US"
}

resource "azurerm_network_security_group" "test" {
  name                = "acctestnsg"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

    security_rule {
    name                       = "RDP"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }  

  security_rule {
    name                       = "SSH"
    priority                   = 400
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "180.10.0.0/24"
    destination_address_prefix = "*"
  } 

  tags = {
    environment = "Production"
  }
}


resource "azurerm_sql_server" "example" {
  name                         = "demo1120939"
  resource_group_name          = azurerm_resource_group.example.name
  location                     = "West US"
  version                      = "12.0"
  administrator_login          = "4dm1n157r470r"
  administrator_login_password = "4-v3ry-53cr37-p455w0rd"
}

resource "azurerm_sql_firewall_rule" "example" {
  name                = "FirewallRule1"
  resource_group_name = azurerm_resource_group.example.name
  server_name         = azurerm_sql_server.example.name
  start_ip_address    = "10.0.17.62"
  end_ip_address      = "10.0.17.62"
}

resource "azurerm_network_watcher" "test" {
  name                = "acctestnw"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_storage_account" "test" {
  name                = "acctestsa"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  account_tier              = "Standard"
  account_kind              = "StorageV2"
  account_replication_type  = "LRS"
  enable_https_traffic_only = true
}

resource "azurerm_network_watcher_flow_log" "test" {
  network_watcher_name = azurerm_network_watcher.test.name
  resource_group_name  = azurerm_resource_group.example.name

  network_security_group_id = azurerm_network_security_group.test.id
  storage_account_id        = azurerm_storage_account.test.id
  enabled                   = true

  retention_policy {
    enabled = true
    days    = 85
  }
}

resource "azurerm_monitor_activity_log_alert" "main1" {
  name                = "example-activitylogalert1"
  resource_group_name = azurerm_resource_group.example.name
  scopes              = [azurerm_resource_group.example.id]
  description         = "This alert will monitor a specific storage account updates."

  criteria {
    resource_id    = azurerm_network_security_group.test.id
    operation_name = "Microsoft.Network/networkSecurityGroups/write"
    category       = "Recommendation"
  }  
}

resource "azurerm_monitor_activity_log_alert" "main2" {
  name                = "example-activitylogalert2"
  resource_group_name = azurerm_resource_group.example.name
  scopes              = [azurerm_resource_group.example.id]
  description         = "This alert will monitor a specific storage account updates."

  criteria {
    resource_id    = azurerm_network_security_group.test.id
    operation_name = "Microsoft.Network/networkSecurityGroups/delete"
    category       = "Recommendation"
  }  
}





