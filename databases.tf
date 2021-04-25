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
  name     = "example-resources"
  location = "West Europe"
}

resource "azurerm_sql_server" "example" {
  name                         = "demosql1120939"
  resource_group_name          = azurerm_resource_group.example.name
  location                     = azurerm_resource_group.example.location
  version                      = "12.0"
  administrator_login          = "mradministrator"
  administrator_login_password = "thisIsDog11"

  extended_auditing_policy {
    storage_endpoint                        = azurerm_storage_account.example.primary_blob_endpoint
    storage_account_access_key              = azurerm_storage_account.example.primary_access_key
    storage_account_access_key_is_secondary = true
    retention_in_days                       = 92
  }
    
  tags = {
    environment = "production"
  }
}

resource "azurerm_storage_account" "example" {
  name                     = "demostorage1120939"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_sql_database" "example" {
  name                = "myexamplesqldatabase"
  resource_group_name = azurerm_resource_group.example.name
  location            = "West US"
  server_name         = azurerm_sql_server.example.name  
}

resource "azurerm_sql_active_directory_administrator" "example" {
  server_name         = azurerm_sql_server.example.name
  resource_group_name = azurerm_resource_group.example.name
  login               = "sqladmin"
  tenant_id           = "38cc1f5c-8095-4452-a193-f19b169c7e03"
  object_id           = "63f9a5ab-99e9-4257-a4b6-17dd04895bd2"
} 

resource "azurerm_postgresql_server" "example" {
  name                = "demopsql"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  administrator_login          = "psqladminun"
  administrator_login_password = "H@Sh1CoR3!"

  sku_name   = "GP_Gen5_4"
  version    = "9.6"
  storage_mb = 640000

  backup_retention_days        = 7
  geo_redundant_backup_enabled = true
  auto_grow_enabled            = true

  public_network_access_enabled    = false
  ssl_enforcement_enabled          = true
  ssl_minimal_tls_version_enforced = "TLS1_2"
}

resource "azurerm_postgresql_database" "example" {
  name                = "exampledb"
  resource_group_name = azurerm_resource_group.example.name
  server_name         = azurerm_postgresql_server.example.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}

resource "azurerm_postgresql_active_directory_administrator" "example" {
  server_name         = azurerm_postgresql_server.example.name
  resource_group_name = azurerm_resource_group.example.name
  login               = "sqladmin"
  tenant_id           = "38cc1f5c-8095-4452-a193-f19b169c7e03"
  object_id           = "63f9a5ab-99e9-4257-a4b6-17dd04895bd2"
}