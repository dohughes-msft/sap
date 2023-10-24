# Create the on-premises Hyper-V host

resource "azurerm_public_ip" "vm" {
  count               = var.use_public_ip_address ? 3 : 0
  name                = "${var.hostname_prefix}-z${count.index+1}-pip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "main" {
  count               = 3
  name                = "${var.hostname_prefix}-z${count.index+1}-nic"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  enable_accelerated_networking = true
  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.workload.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.use_public_ip_address ? azurerm_public_ip.vm[count.index].id : null
  }
}

resource "azurerm_linux_virtual_machine" "main" {
  count                           = 3
  name                            = "${var.hostname_prefix}-z${count.index+1}"
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  size                            = var.host_size
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false
  zone                            = count.index + 1
  identity {
    type = "SystemAssigned"
  }
  network_interface_ids = [
    azurerm_network_interface.main[count.index].id
  ]

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Premium_LRS"
    caching              = "ReadWrite"
  }
  boot_diagnostics {}
}
