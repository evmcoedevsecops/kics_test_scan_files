terraform {
  backend "remote" {
    organization = "caliber"

    workspaces {
      name = "Test3"
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


resource "azurerm_virtual_network" "example" {
  name                = "virtnetname"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "example" {
  name                 = "subnetname"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefix       = "10.0.2.0/24"
  service_endpoints    = ["Microsoft.Sql", "Microsoft.Storage"]
}

resource "azurerm_storage_account" "example" {
  name                     = "demo11209393"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  enable_https_traffic_only = "true" 

  queue_properties  {
        logging {
          delete                = true
          read                  = true
          version               = "1"
          write                 = true
          retention_policy_days = "10"
        }
    } 
  

  tags = {
    environment = "staging"
  }  

  network_rules {
    default_action             = "Deny"  
    bypass                     = ["AzureServices"]
    ip_rules                   = ["100.0.0.1"]
    virtual_network_subnet_ids = [azurerm_subnet.example.id]
  }   
}


resource "azurerm_storage_container" "example" {
  name                  = "demo2509--provisioning"
  storage_account_name  = azurerm_storage_account.example.name 
  container_access_type = "private"  
}


data "azurerm_storage_account_sas" "example" {
  connection_string = azurerm_storage_account.example.primary_connection_string
  https_only        = true
  signed_version    = "2017-07-29"

  resource_types {
    service   = true
    container = false
    object    = false
  }

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  start  = "2018-03-21"
  expiry = "2020-03-21"

  permissions {
    read    = true
    write   = true
    delete  = false
    list    = false
    add     = true
    create  = true
    update  = false
    process = false
  }
}




resource "azurerm_eventhub_namespace" "example" {
  name                = "demo1120939"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "Standard"
  capacity            = 2
}

resource "azurerm_monitor_log_profile" "example" {
  name = "default"

  categories = [
    "Action",
    "Delete",
    "Write",
  ]

  locations = [
    "westus",
    "global",
  ]

  # RootManageSharedAccessKey is created by default with listen, send, manage permissions
  servicebus_rule_id = "${azurerm_eventhub_namespace.example.id}/authorizationrules/RootManageSharedAccessKey"
  storage_account_id = azurerm_storage_account.example.id

  retention_policy {
    enabled = true
    days    = 7
  }
}






