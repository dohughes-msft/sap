# Create the Azure resources needed for Files

resource "random_string" "storage_suffix" {
  length           = 8
  numeric          = true
  lower            = true
  special          = false
  upper            = false
}

resource "azurerm_storage_account" "default" {
  name                     = "${var.storage_account_prefix}${random_string.storage_suffix.result}"
  location                 = azurerm_resource_group.azure.location
  resource_group_name      = azurerm_resource_group.azure.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
