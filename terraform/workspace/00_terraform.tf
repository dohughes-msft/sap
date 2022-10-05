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
    key                  = "all.tfstate"
  }
}
