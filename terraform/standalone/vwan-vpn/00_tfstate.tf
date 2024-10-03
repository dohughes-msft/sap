terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.0.0"
    }
  }
  backend "local" {
    path = "vwan-vpn.tfstate"
  }
}

provider "azurerm" {
  features {}
}
