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