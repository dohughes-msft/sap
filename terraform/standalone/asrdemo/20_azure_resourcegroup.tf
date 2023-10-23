resource "azurerm_resource_group" "azure" {
  name     = "${var.azure_resource_group_name}-${var.group_label}"
  location = var.location
}
