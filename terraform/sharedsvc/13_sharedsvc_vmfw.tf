variable "vmfw_vmprefix" {
  type = string
  default = "vmfw"
}
variable "vmfw_vmcount" {
  type = number
  default = 1
}
variable "vmfw_ip_addresses" {
  type    = list(string)
  default = ["10.0.3.4"]
}

resource "azurerm_public_ip" "vmfw" {
  count               = var.vmfw_vmcount
  name                = "${var.vmfw_vmprefix}${count.index+1}-pip"
  resource_group_name = azurerm_resource_group.shared-services-ne-rg1.name
  location            = azurerm_resource_group.shared-services-ne-rg1.location
  allocation_method   = "Dynamic"
  domain_name_label   ="${var.vmfw_vmprefix}${count.index+1}"
}

resource "azurerm_network_interface" "vmfw" {
  count                = var.vmfw_vmcount
  name                 = "${var.vmfw_vmprefix}${count.index+1}-nic"
  resource_group_name  = azurerm_resource_group.shared-services-ne-rg1.name
  location             = azurerm_resource_group.shared-services-ne-rg1.location
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = data.terraform_remote_state.connectivity.outputs.vmfw_subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.vmfw_ip_addresses[count.index]
    public_ip_address_id          = azurerm_public_ip.vmfw[count.index].id
  }
}

resource "azurerm_linux_virtual_machine" "vmfw" {
  count                           = var.vmfw_vmcount
  name                            = "${var.vmfw_vmprefix}${count.index+1}"
  resource_group_name             = azurerm_resource_group.shared-services-ne-rg1.name
  location                        = azurerm_resource_group.shared-services-ne-rg1.location
  size                            = "Standard_D4ds_v5"
  disable_password_authentication = false
  admin_username                  = "adminuser"
  admin_password                  = var.admin_password
  identity {
    type = "SystemAssigned"
  }
  network_interface_ids = [
    azurerm_network_interface.vmfw[count.index].id,
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
