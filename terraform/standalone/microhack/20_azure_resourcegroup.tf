resource "azurerm_resource_group" "azure" {
  name     = "${var.global_label}-${var.group_label}-azure-rg"
  location = var.location
}
