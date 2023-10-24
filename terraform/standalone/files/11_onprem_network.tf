# Create the simulated on-premises network

resource "azurerm_virtual_network" "onprem" {
  name                = var.onprem_vnet_name
  location            = azurerm_resource_group.onprem.location
  resource_group_name = azurerm_resource_group.onprem.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "onprem-workload" {
  name                 = var.onprem_subnet_name
  resource_group_name  = azurerm_resource_group.onprem.name
  virtual_network_name = azurerm_virtual_network.onprem.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "onprem-bastion" {
  count = var.use_bastion ? 1 : 0
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.onprem.name
  virtual_network_name = azurerm_virtual_network.onprem.name
  address_prefixes     = ["10.0.10.0/24"]
}

resource "azurerm_network_security_group" "onprem" {
  name                = var.onprem_nsg_name
  location            = azurerm_resource_group.onprem.location
  resource_group_name = azurerm_resource_group.onprem.name
}

resource "azurerm_network_security_rule" "onprem-public" {
  count                       = var.use_public_ip_address ? 1 : 0
  name                        = "AllowAdmin"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["22","3389"]
  source_address_prefix       = var.admin_ip_address
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.onprem.name
  network_security_group_name = azurerm_network_security_group.onprem.name
}

resource "azurerm_subnet_network_security_group_association" "onprem-nsg-workload-subnet" {
  subnet_id                 = azurerm_subnet.onprem-workload.id
  network_security_group_id = azurerm_network_security_group.onprem.id
}

resource "azurerm_public_ip" "onprem-bastion" {
  count = var.use_bastion ? 1 : 0
  name                = "AzureBastion-pip"
  location            = azurerm_resource_group.onprem.location
  resource_group_name = azurerm_resource_group.onprem.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "onprem" {
  count = var.use_bastion ? 1 : 0
  name                = "onprem-bastion"
  location            = azurerm_resource_group.onprem.location
  resource_group_name = azurerm_resource_group.onprem.name
  ip_configuration {
    name                 = "onprem-bastion-configuration"
    subnet_id            = azurerm_subnet.onprem-bastion[0].id
    public_ip_address_id = azurerm_public_ip.onprem-bastion[0].id
  }
}
