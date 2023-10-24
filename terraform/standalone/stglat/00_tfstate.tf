terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.0.0"
    }
  }
  backend "local" {
    path = "storagetest.tfstate"
  }
}

provider "azurerm" {
  features {}
}
