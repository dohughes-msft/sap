
resource "azurerm_public_ip" "dbserver" {
  #count               = var.dbserver_vmcount
  #name                = "${var.dbserver_vmprefix}${count.index+1}-pip"
  name                = "${var.prefix}-db-pip"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Dynamic"
  #domain_name_label   ="${var.dbserver_vmprefix}${count.index+1}"
  domain_name_label   ="${var.prefix}-db"
}

resource "azurerm_network_interface" "dbserver" {
  #count                = var.dbserver_vmcount
  #name                 = "${var.dbserver_vmprefix}${count.index+1}-nic"
  name                 = "${var.prefix}-db-nic"
  resource_group_name  = azurerm_resource_group.main.name
  location             = azurerm_resource_group.main.location

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = data.terraform_remote_state.connectivity.outputs.spoke1_db_subnet_id
    private_ip_address_allocation = "Dynamic"
    #private_ip_address            = var.dbserver_ip_addresses[count.index]
    public_ip_address_id          = azurerm_public_ip.dbserver.id
  }
}

resource "azurerm_linux_virtual_machine" "dbserver" {
  #count                           = var.dbserver_vmcount
  #name                            = "${var.dbserver_vmprefix}${count.index+1}"
  name                            = "${var.prefix}-db"
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  size                            = "Standard_D4ds_v5"
  disable_password_authentication = false
  admin_username                  = "adminuser"
  admin_password                  = var.admin_password
  identity {
    type = "SystemAssigned"
  }
  network_interface_ids = [
    azurerm_network_interface.dbserver.id,
  ]

  source_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Premium_LRS"
    caching              = "ReadWrite"
  }
  boot_diagnostics {}
}
