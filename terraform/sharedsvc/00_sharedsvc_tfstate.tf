terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.0.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "terraform-ne-rg1"
    storage_account_name = "tfstatene"
    container_name       = "tfstate"
    key                  = "sharedsvc.tfstate"
  }
}

provider "azurerm" {
  features {}
}

data "terraform_remote_state" "connectivity" {
  backend = "azurerm"
  config = {
    resource_group_name  = "terraform-ne-rg1"
    storage_account_name = "tfstatene"
    container_name       = "tfstate"
    key                  = "connectivity.tfstate"
  }
}
