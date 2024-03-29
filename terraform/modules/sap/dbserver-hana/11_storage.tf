resource "azurerm_managed_disk" "usrsap" {
  count                = var.vm_count
  name                 = "${var.vm_name}${count.index+1}-usrsap"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = local.disk_config[var.vm_size].usrsapsize
}

resource "azurerm_virtual_machine_data_disk_attachment" "usrsap" {
  count              = var.vm_count
  managed_disk_id    = azurerm_managed_disk.usrsap[count.index].id
  virtual_machine_id = azurerm_linux_virtual_machine.main[count.index].id
  lun                = 0
  caching            = "ReadWrite"
}

resource "azurerm_managed_disk" "shared" {
  count                = var.vm_count
  name                 = "${var.vm_name}${count.index+1}-shared"
  resource_group_name  = var.resource_group_name
  location             = var.location
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = local.disk_config[var.vm_size].sharedsize
}

resource "azurerm_virtual_machine_data_disk_attachment" "shared" {
  count              = var.vm_count
  managed_disk_id    = azurerm_managed_disk.shared[count.index].id
  virtual_machine_id = azurerm_linux_virtual_machine.main[count.index].id
  lun                = 1
  caching            = "ReadWrite"
}

resource "azurerm_managed_disk" "data" {
  count                = var.vm_count*local.disk_config[var.vm_size].datacount
  name                 = "${var.vm_name}${count.index%var.vm_count+1}-datadisk${floor(count.index/var.vm_count)+1}"
  resource_group_name  = var.resource_group_name
  location             = var.location
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = local.disk_config[var.vm_size].datasize
}

resource "azurerm_virtual_machine_data_disk_attachment" "data" {
  count              = var.vm_count*local.disk_config[var.vm_size].datacount
  managed_disk_id    = azurerm_managed_disk.data[count.index].id
  virtual_machine_id = azurerm_linux_virtual_machine.main[count.index%var.vm_count].id
  lun                = floor(count.index/var.vm_count)+2
  caching            = "None"
}


resource "azurerm_managed_disk" "log" {
  count                = var.vm_count*local.disk_config[var.vm_size].logcount
  name                 = "${var.vm_name}${count.index%var.vm_count+1}-logdisk${floor(count.index/var.vm_count)+1}"
  resource_group_name  = var.resource_group_name
  location             = var.location
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = local.disk_config[var.vm_size].logsize
}

resource "azurerm_virtual_machine_data_disk_attachment" "log" {
  count              = var.vm_count*local.disk_config[var.vm_size].logcount
  managed_disk_id    = azurerm_managed_disk.log[count.index].id
  virtual_machine_id = azurerm_linux_virtual_machine.main[count.index%var.vm_count].id
  lun                = floor(count.index/var.vm_count)+local.disk_config[var.vm_size].datacount+2
  caching            = "None"
}
