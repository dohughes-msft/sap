resource "azurerm_storage_account" "sharedstgne" {
  name                            = "sharedstgne"
  resource_group_name             = azurerm_resource_group.management-northeurope.name
  location                        = azurerm_resource_group.management-northeurope.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  allow_nested_items_to_be_public = false
}
