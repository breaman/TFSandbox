terraform {
  backend "azurerm" {
    resource_group_name  = "stokestfstates"
    storage_account_name = "stokestf"
    container_name       = "tfstatedevops"
    key                  = "stokesterraform.tfstate"
  }
}

provider "azurerm" {
  version = "~>2.0"
  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "stokesops" {
  name     = "stokesops"
  location = "eastus2"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "stokesops-vnet"
  address_space       = ["192.168.0.0/16"]
  location            = "eastus2"
  resource_group_name = azurerm_resource_group.stokesops.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnet"
  resource_group_name  = azurerm_resource_group.stokesops.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefix       = "192.168.0.0/24"
}

resource "azurerm_app_service_plan" "example" {
  name                = "example-appserviceplan"
  location            = azurerm_resource_group.stokesops.location
  resource_group_name = azurerm_resource_group.stokesops.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "example" {
  name                = "app-service"
  location            = azurerm_resource_group.stokesops.location
  resource_group_name = azurerm_resource_group.stokesops.name
  app_service_plan_id = azurerm_app_service_plan.example.id

  site_config {
    dotnet_framework_version = "v4.0"
    scm_type                 = "LocalGit"
    php_version              = "2.2"
  }

  app_settings = {
    "SOME_KEY" = "some-value"
  }

  connection_string {
    name  = "Database"
    type  = "SQLServer"
    value = "Server=some-server.mydomain.com;Integrated Security=SSPI"
  }
}