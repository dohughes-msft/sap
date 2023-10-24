# Create the on-premises Hyper-V host

resource "azurerm_public_ip" "default" {
  count               = var.use_public_ip_address ? 1 : 0
  name                = "${var.hyperv_hostname}-pip"
  location            = azurerm_resource_group.onprem.location
  resource_group_name = azurerm_resource_group.onprem.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "default" {
  name                = "${var.hyperv_hostname}-nic"
  resource_group_name = azurerm_resource_group.onprem.name
  location            = azurerm_resource_group.onprem.location
  enable_accelerated_networking = true
  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.onprem-workload.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.0.4"
    public_ip_address_id          = var.use_public_ip_address ? azurerm_public_ip.default[0].id : null
  }
}

resource "azurerm_windows_virtual_machine" "default" {
  name                            = var.hyperv_hostname
  resource_group_name             = azurerm_resource_group.onprem.name
  location                        = azurerm_resource_group.onprem.location
  size                            = var.hyperv_host_size
  admin_username                  = "adminuser"
  admin_password                  = var.admin_password
  identity {
    type = "SystemAssigned"
  }
  network_interface_ids = [
    azurerm_network_interface.default.id
  ]

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-datacenter-gensecond"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Premium_LRS"
    caching              = "ReadWrite"
  }
  boot_diagnostics {}
}

resource "azurerm_managed_disk" "default" {
  name                 = "${var.hyperv_hostname}-datadisk"
  location             = azurerm_resource_group.onprem.location
  resource_group_name  = azurerm_resource_group.onprem.name
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
