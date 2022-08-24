variable "advm_prefix" {
  type = string
  default = "advm"
}

variable "advm_count" {
  type = number
  default = 2
}

variable "advm_ip_addresses" {
  type    = list(string)
  default = ["10.0.0.5","10.0.0.6"]
}

resource "azurerm_public_ip" "advm" {
  count               = var.advm_count
  name                = "${var.advm_prefix}${count.index+1}-pip"
  resource_group_name = azurerm_resource_group.shared-services-ne-rg1.name
  location            = azurerm_resource_group.shared-services-ne-rg1.location
  allocation_method   = "Dynamic"
  domain_name_label   ="${var.advm_prefix}${count.index+1}"
}

resource "azurerm_network_interface" "advm" {
  count               = var.advm_count
  name                = "${var.advm_prefix}${count.index+1}-nic"
  resource_group_name = azurerm_resource_group.shared-services-ne-rg1.name
  location            = azurerm_resource_group.shared-services-ne-rg1.location

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = data.terraform_remote_state.connectivity.outputs.mgmt_subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.advm_ip_addresses[count.index]
    public_ip_address_id          = azurerm_public_ip.advm[count.index].id
  }
}

resource "azurerm_windows_virtual_machine" "advm" {
  count                           = var.advm_count
  name                            = "${var.advm_prefix}${count.index+1}"
  resource_group_name             = azurerm_resource_group.shared-services-ne-rg1.name
  location                        = azurerm_resource_group.shared-services-ne-rg1.location
  size                            = "Standard_D4ds_v5"
  admin_username                  = "adminuser"
  admin_password                  = var.admin_password
  identity {
    type = "SystemAssigned"
  }
  network_interface_ids = [
    azurerm_network_interface.advm[count.index].id,
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

# resource "azurerm_windows_virtual_machine" "advm" {}