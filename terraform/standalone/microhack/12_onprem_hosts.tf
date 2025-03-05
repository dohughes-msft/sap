# Create the on-premises hosts

locals {
  deploymentscript_winweb1 = "https://raw.githubusercontent.com/latj/MicroHack/main/03-Azure/01-03-Infrastructure/06_Migration_Datacenter_Modernization/resources/deploy.ps1"
  deploymentscript_discovery = "https://raw.githubusercontent.com/latj/MicroHack/main/03-Azure/01-03-Infrastructure/06_Migration_Datacenter_Modernization/resources/discovery.ps1"
  deploymentscript_migration = "https://raw.githubusercontent.com/latj/MicroHack/main/03-Azure/01-03-Infrastructure/06_Migration_Datacenter_Modernization/resources/migration.ps1"  
}

resource "azurerm_network_interface" "winweb1" {
  name                = "winweb1-nic"
  resource_group_name = azurerm_resource_group.onprem.name
  location            = azurerm_resource_group.onprem.location
  accelerated_networking_enabled = true
  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.onprem-workload.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.1.1.5"
  }
}

resource "azurerm_windows_virtual_machine" "winweb1" {
  name                            = "winweb1"
  resource_group_name             = azurerm_resource_group.onprem.name
  location                        = azurerm_resource_group.onprem.location
  size                            = var.workload_host_size
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  identity {
    type = "SystemAssigned"
  }
  network_interface_ids = [
    azurerm_network_interface.winweb1.id
  ]

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-smalldisk-g2"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "StandardSSD_LRS"
    caching              = "ReadWrite"
  }
  boot_diagnostics {}
  vm_agent_platform_updates_enabled = true
}

resource "azurerm_virtual_machine_extension" "winweb1-cse" {
  name                 = "winweb1-cse"
  virtual_machine_id   = azurerm_windows_virtual_machine.winweb1.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"
  settings = <<SETTINGS
  {
      "commandToExecute": "powershell -ExecutionPolicy Unrestricted Add-WindowsFeature Web-Server -IncludeManagementTools; powershell -ExecutionPolicy Unrestricted -File deploy.ps1",
      "fileUris": ["${local.deploymentscript_winweb1}"]
  }
SETTINGS
}

resource "azurerm_network_interface" "lnxweb1" {
  name                = "lnxweb1-nic"
  resource_group_name = azurerm_resource_group.onprem.name
  location            = azurerm_resource_group.onprem.location
  accelerated_networking_enabled = true
  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.onprem-workload.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.1.1.4"
  }
}

resource "azurerm_linux_virtual_machine" "lnxweb1" {
  name                            = "lnxweb1"
  resource_group_name             = azurerm_resource_group.onprem.name
  location                        = azurerm_resource_group.onprem.location
  size                            = var.workload_host_size
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false
  identity {
    type = "SystemAssigned"
  }
  network_interface_ids = [
    azurerm_network_interface.lnxweb1.id
  ]

  source_image_reference {
    publisher = "RedHat"
    offer     = "RHEL"
    sku       = "86-gen2"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "StandardSSD_LRS"
    caching              = "ReadWrite"
  }
  boot_diagnostics {}
}

resource "azurerm_virtual_machine_extension" "lnxweb1-cse" {
  name                 = "lnxweb1-cse"
  virtual_machine_id   = azurerm_linux_virtual_machine.lnxweb1.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.1"
  settings = <<SETTINGS
  {
      "commandToExecute": "sudo firewall-cmd --zone=public --add-port=80/tcp --permanent && sudo firewall-cmd --reload && sudo python3 -m http.server 80 &"
  }
SETTINGS
}

resource "azurerm_network_interface" "discovery" {
  name                = "discovery-nic"
  resource_group_name = azurerm_resource_group.onprem.name
  location            = azurerm_resource_group.onprem.location
  accelerated_networking_enabled = true
  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.onprem-workload.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.1.1.6"
  }
}

resource "azurerm_windows_virtual_machine" "discovery" {
  name                            = "discovery"
  resource_group_name             = azurerm_resource_group.onprem.name
  location                        = azurerm_resource_group.onprem.location
  size                            = var.migration_host_size
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  identity {
    type = "SystemAssigned"
  }
  network_interface_ids = [
    azurerm_network_interface.discovery.id
  ]

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-smalldisk-g2"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "StandardSSD_LRS"
    caching              = "ReadWrite"
  }
  boot_diagnostics {}
  vm_agent_platform_updates_enabled = true
}

resource "azurerm_virtual_machine_extension" "discovery-cse" {
  name                 = "discovery-cse"
  virtual_machine_id   = azurerm_windows_virtual_machine.discovery.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"
  settings = <<SETTINGS
  {
      "commandToExecute": "powershell -ExecutionPolicy Unrestricted Add-WindowsFeature Web-Server -IncludeManagementTools; powershell -ExecutionPolicy Unrestricted -File discovery.ps1",
      "fileUris": ["${local.deploymentscript_discovery}"]
  }
SETTINGS
}

resource "azurerm_network_interface" "migration" {
  name                = "migration-nic"
  resource_group_name = azurerm_resource_group.onprem.name
  location            = azurerm_resource_group.onprem.location
  accelerated_networking_enabled = true
  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.onprem-workload.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.1.1.7"
  }
}

resource "azurerm_windows_virtual_machine" "migration" {
  name                            = "migration"
  resource_group_name             = azurerm_resource_group.onprem.name
  location                        = azurerm_resource_group.onprem.location
  size                            = var.workload_host_size
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  identity {
    type = "SystemAssigned"
  }
  network_interface_ids = [
    azurerm_network_interface.migration.id
  ]

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-datacenter-smalldisk-g2"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "StandardSSD_LRS"
    caching              = "ReadWrite"
  }
  boot_diagnostics {}
  vm_agent_platform_updates_enabled = true
}

resource "azurerm_virtual_machine_extension" "migration-cse" {
  name                 = "migration-cse"
  virtual_machine_id   = azurerm_windows_virtual_machine.migration.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"
  settings = <<SETTINGS
  {
      "commandToExecute": "powershell -ExecutionPolicy Unrestricted Add-WindowsFeature Web-Server -IncludeManagementTools; powershell -ExecutionPolicy Unrestricted -File migration.ps1",
      "fileUris": ["${local.deploymentscript_migration}"]
  }
SETTINGS
}

# Public IP for load balancer
resource "azurerm_public_ip" "onprem-lb" {
  name                = "onprem-lb-pip"
  location            = azurerm_resource_group.onprem.location
  resource_group_name = azurerm_resource_group.onprem.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "onprem-lb-outbound" {
  name                = "onprem-lb-outbound-pip"
  location            = azurerm_resource_group.onprem.location
  resource_group_name = azurerm_resource_group.onprem.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Load balancer for all VM hosts
resource "azurerm_lb" "onprem" {
  name                = "onprem-lb"
  resource_group_name = azurerm_resource_group.onprem.name
  location            = azurerm_resource_group.onprem.location
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = "PublicIPAddress"
    public_ip_address_id          = azurerm_public_ip.onprem-lb.id
  }

  frontend_ip_configuration {
    name                          = "OutboundPublicIPAddress"
    public_ip_address_id          = azurerm_public_ip.onprem-lb-outbound.id
  }
}

resource azurerm_lb_backend_address_pool "backend" {
  loadbalancer_id     = azurerm_lb.onprem.id
  name                = "LoadBalancerBackEndPool"
}

resource "azurerm_lb_backend_address_pool_address" "winweb1" {
  name                                = "winweb1"
  backend_address_pool_id             = azurerm_lb_backend_address_pool.backend.id
  virtual_network_id                  = azurerm_virtual_network.onprem.id
  ip_address                          = azurerm_network_interface.winweb1.private_ip_address
}

resource "azurerm_lb_backend_address_pool_address" "lnxweb1" {
  name                                = "lnxweb1"
  backend_address_pool_id             = azurerm_lb_backend_address_pool.backend.id
  virtual_network_id                  = azurerm_virtual_network.onprem.id
  ip_address                          = azurerm_network_interface.lnxweb1.private_ip_address
}

resource azurerm_lb_backend_address_pool "backend-outbound" {
  loadbalancer_id     = azurerm_lb.onprem.id
  name                = "LoadBalancerBackEndPoolOutbound"
}

resource "azurerm_lb_backend_address_pool_address" "winweb1-outbound" {
  name                                = "winweb1-outbound"
  backend_address_pool_id             = azurerm_lb_backend_address_pool.backend-outbound.id
  virtual_network_id                  = azurerm_virtual_network.onprem.id
  ip_address                          = azurerm_network_interface.winweb1.private_ip_address
}

resource "azurerm_lb_backend_address_pool_address" "lnxweb1-outbound" {
  name                                = "lnxweb1-outbound"
  backend_address_pool_id             = azurerm_lb_backend_address_pool.backend-outbound.id
  virtual_network_id                  = azurerm_virtual_network.onprem.id
  ip_address                          = azurerm_network_interface.lnxweb1.private_ip_address
}

resource "azurerm_lb_probe" "http" {
  loadbalancer_id = azurerm_lb.onprem.id
  name                = "http"
  port                = 80
  protocol            = "Tcp"
  interval_in_seconds = 5
  number_of_probes    = 2
}

resource "azurerm_lb_rule" "http" {
  loadbalancer_id                = azurerm_lb.onprem.id
  name                           = "myHTTPRule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_ids = [
    azurerm_lb_backend_address_pool.backend.id
  ]
  probe_id                       = azurerm_lb_probe.http.id
}

resource "azurerm_lb_outbound_rule" "tcpoutbound" {
  name                    = "OutboundRule"
  loadbalancer_id         = azurerm_lb.onprem.id
  protocol                = "Tcp"
  backend_address_pool_id = azurerm_lb_backend_address_pool.backend.id

  frontend_ip_configuration {
    name = "OutboundPublicIPAddress"
  }
}