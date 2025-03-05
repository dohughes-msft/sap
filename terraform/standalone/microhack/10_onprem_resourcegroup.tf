resource "azurerm_resource_group" "onprem" {
  name     = "${var.global_label}-${var.group_label}-onprem-rg"
  location = var.location
}
