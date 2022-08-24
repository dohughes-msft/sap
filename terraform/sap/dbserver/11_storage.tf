resource "azurerm_managed_disk" "usrsap" {
  name                 = "${var.prefix}-usrsap"
  location             = azurerm_resource_group.main.location
  resource_group_name  = azurerm_resource_group.main.name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = local.disk_config[var.vmsize].usrsapsize
}

resource "azurerm_virtual_machine_data_disk_attachment" "usrsap" {
  managed_disk_id    = azurerm_managed_disk.usrsap.id
  virtual_machine_id = azurerm_linux_virtual_machine.dbserver.id
  lun                = 0
  caching            = "ReadWrite"
}

resource "azurerm_managed_disk" "shared" {
  name                 = "${var.prefix}-shared"
  location             = azurerm_resource_group.main.location
  resource_group_name  = azurerm_resource_group.main.name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = local.disk_config[var.vmsize].sharedsize
}

resource "azurerm_virtual_machine_data_disk_attachment" "shared" {
  managed_disk_id    = azurerm_managed_disk.shared.id
  virtual_machine_id = azurerm_linux_virtual_machine.dbserver.id
  lun                = 1
  caching            = "ReadWrite"
}

resource "azurerm_managed_disk" "data" {
  count                = local.disk_config[var.vmsize].datacount
  name                 = "${var.prefix}-datadisk${count.index+1}"
  location             = azurerm_resource_group.main.location
  resource_group_name  = azurerm_resource_group.main.name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = local.disk_config[var.vmsize].datasize
}

resource "azurerm_virtual_machine_data_disk_attachment" "data" {
  count              = local.disk_config[var.vmsize].datacount
  managed_disk_id    = azurerm_managed_disk.data[count.index].id
  virtual_machine_id = azurerm_linux_virtual_machine.dbserver.id
  lun                = count.index+2
  caching            = "None"
}

resource "azurerm_managed_disk" "log" {
  count                = local.disk_config[var.vmsize].logcount
  name                 = "${var.prefix}-logdisk${count.index+1}"
  location             = azurerm_resource_group.main.location
  resource_group_name  = azurerm_resource_group.main.name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = local.disk_config[var.vmsize].logsize
}

resource "azurerm_virtual_machine_data_disk_attachment" "log" {
  count              = local.disk_config[var.vmsize].logcount
  managed_disk_id    = azurerm_managed_disk.log[count.index].id
  virtual_machine_id = azurerm_linux_virtual_machine.dbserver.id
  lun                = count.index+local.disk_config[var.vmsize].datacount+2
  caching            = "None"
}
