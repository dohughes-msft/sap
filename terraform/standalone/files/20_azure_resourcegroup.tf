resource "azurerm_resource_group" "azure" {
  name     = var.azure_resource_group_name
  location = var.location
}
