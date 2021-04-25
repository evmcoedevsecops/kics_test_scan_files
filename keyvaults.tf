
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "my-resource-group"
  location = "West US"
}

resource "azurerm_key_vault" "example" {
  name                = "vaultkey1120939"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  tenant_id           = "38cc1f5c-8095-4452-a193-f19b169c7e03"

  sku_name = "premium" 
  soft_delete_enabled         = false
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false 
}

resource "azurerm_key_vault_key" "generated" {
  name         = "generated-certificate"
  key_vault_id = azurerm_key_vault.example.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
    
}

resource "azurerm_key_vault_secret" "example" {
  name         = "secret1120939"
  value        = "szechuan"
  key_vault_id = azurerm_key_vault.example.id  
  expiration_date = "2020-12-18T15:04:08Z"  
}

resource "azurerm_kubernetes_cluster" "example" {
  name                = "example-aks1"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  dns_prefix          = "exampleaks1"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }
    
  identity {
    type = "SystemAssigned"
  }

  role_based_access_control {
      enabled = true
  }   
}



