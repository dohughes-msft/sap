resource "azurerm_resource_group" "onprem" {
  name     = var.onprem_resource_group_name
  location = var.location
}
