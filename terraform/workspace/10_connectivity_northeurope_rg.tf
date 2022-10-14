resource "azurerm_resource_group" "connectivity-northeurope" {
  name     = "connectivity-northeurope-rg1"
  location = "northeurope"
}

resource "azurerm_resource_group" "onprem-northeurope" {
  name     = "onprem-northeurope-rg1"
  location = "northeurope"
}
