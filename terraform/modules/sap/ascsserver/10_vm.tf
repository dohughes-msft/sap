
resource "azurerm_public_ip" "main" {
  count               = var.vm_count
  name                = "${var.vm_name}${count.index+1}-pip"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Dynamic"
  #domain_name_label   = "${var.dbserver_vmprefix}${count.index+1}"
  domain_name_label   = "${var.vm_name}${count.index+1}"
}

resource "azurerm_network_interface" "main" {
  count                         = var.vm_count
  name                          = "${var.vm_name}${count.index+1}-nic"
  resource_group_name           = var.resource_group_name
  location                      = var.location
  enable_accelerated_networking = true

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.ip_address[count.index]
    public_ip_address_id          = azurerm_public_ip.main[count.index].id
  }
}

resource "azurerm_linux_virtual_machine" "main" {
  count                           = var.vm_count
  name                            = "${var.vm_name}${count.index+1}"
  resource_group_name             = var.resource_group_name
  location                        = var.location
  size                            = var.vm_size
  disable_password_authentication = false
  admin_username                  = var.admin_user
  admin_password                  = var.admin_password
  identity {
    type = "SystemAssigned"
  }
  network_interface_ids = [
    azurerm_network_interface.main[count.index].id,
  ]

  source_image_reference {
    publisher = "suse"
    offer     = "sles-sap-12-sp5"
    sku       = "gen2"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Premium_LRS"
    caching              = "ReadWrite"
  }
  boot_diagnostics {}
}
