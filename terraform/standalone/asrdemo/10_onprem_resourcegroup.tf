resource "azurerm_resource_group" "onprem" {
  name     = "${var.onprem_resource_group_name}-${var.group_label}"
  location = var.location
}
