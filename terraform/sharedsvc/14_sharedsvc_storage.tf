resource "azurerm_storage_account" "sharedstgne" {
  name                            = "sharedstgne"
  resource_group_name             = azurerm_resource_group.shared-services-ne-rg1.name
  location                        = azurerm_resource_group.shared-services-ne-rg1.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  allow_nested_items_to_be_public = false
}