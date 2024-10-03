resource "azurerm_resource_group" "main" {
  name     = "vwan-vpn-rg1"
  location = var.location
}
