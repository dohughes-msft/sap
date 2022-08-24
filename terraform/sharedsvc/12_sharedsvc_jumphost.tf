variable "jumphost_vmprefix" {
  type = string
  default = "jumphost"
}

variable "jumphost_vmcount" {
  type = number
  default = 1
}

variable "jumphost_ip_addresses" {
  type    = list(string)
  default = ["10.0.0.4"]
}

resource "azurerm_public_ip" "jumphost" {
  count               = var.jumphost_vmcount
  name                = "${var.jumphost_vmprefix}${count.index+1}-pip"
  resource_group_name = azurerm_resource_group.shared-services-ne-rg1.name
  location            = azurerm_resource_group.shared-services-ne-rg1.location
  allocation_method   = "Dynamic"
  domain_name_label   ="${var.jumphost_vmprefix}${count.index+1}"
}

resource "azurerm_network_interface" "jumphost" {
  count               = var.jumphost_vmcount
  name                = "${var.jumphost_vmprefix}${count.index+1}-nic"
  resource_group_name = azurerm_resource_group.shared-services-ne-rg1.name
  location            = azurerm_resource_group.shared-services-ne-rg1.location

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = data.terraform_remote_state.connectivity.outputs.mgmt_subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.jumphost_ip_addresses[count.index]
    public_ip_address_id          = azurerm_public_ip.jumphost[count.index].id
  }
}

resource "azurerm_windows_virtual_machine" "jumphost" {
  count                           = var.jumphost_vmcount
  name                            = "${var.jumphost_vmprefix}${count.index+1}"
  resource_group_name             = azurerm_resource_group.shared-services-ne-rg1.name
  location                        = azurerm_resource_group.shared-services-ne-rg1.location
  size                            = "Standard_D4ds_v5"
  admin_username                  = "adminuser"
  admin_password                  = var.admin_password
  identity {
    type = "SystemAssigned"
  }
  network_interface_ids = [
    azurerm_network_interface.jumphost[count.index].id,
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
