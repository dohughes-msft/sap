# Create the Azure resources needed for site recovery

resource "random_string" "storage_suffix" {
  length           = 8
  numeric          = true
  lower            = true
  special          = false
  upper            = false
}

resource "azurerm_storage_account" "standard" {
  name                     = "${var.storage_account_prefix}std${random_string.storage_suffix.result}"
  location                 = azurerm_resource_group.main.location
  resource_group_name      = azurerm_resource_group.main.name
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "standard" {
  name                 = "stdfileshare"
  storage_account_name = azurerm_storage_account.standard.name
  quota                = 100
}

resource "azurerm_storage_account" "premiumfile" {
  name                      = "${var.storage_account_prefix}prem${random_string.storage_suffix.result}"
  location                  = azurerm_resource_group.main.location
  resource_group_name       = azurerm_resource_group.main.name
  account_kind              = "FileStorage"
  account_tier              = "Premium"
  account_replication_type  = "LRS"
  enable_https_traffic_only = false
}

resource "azurerm_storage_share" "premium" {
  name                 = "premfileshare"
  storage_account_name = azurerm_storage_account.premiumfile.name
  quota                = 100
  enabled_protocol     = "NFS"
}

/*
resource "azurerm_managed_disk" "default" {
  name                 = "${var.hyperv_hostname}-datadisk"
  location             = azurerm_resource_group.main.location
  resource_group_name  = azurerm_resource_group.main.name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = "512"
}

resource "azurerm_virtual_machine_data_disk_attachment" "default" {
  managed_disk_id    = azurerm_managed_disk.default.id
  virtual_machine_id = azurerm_windows_virtual_machine.default.id
  lun                = "0"
  caching            = "ReadWrite"
}
*/