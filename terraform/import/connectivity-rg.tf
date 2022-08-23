resource "azurerm_resource_group" "connectivity-ne-rg1" {
  name     = "connectivity-ne-rg1"
  location = "northeurope"
}

output "connectivity_rg_name" {
  value = azurerm_resource_group.connectivity-ne-rg1.name
}

output "connectivity_rg_loc" {
  value = azurerm_resource_group.connectivity-ne-rg1.location
}
