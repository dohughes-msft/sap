# Create the Azure network

resource "azurerm_virtual_network" "azure" {
  name                = "azure-vnet"
  location            = azurerm_resource_group.azure.location
  resource_group_name = azurerm_resource_group.azure.name
  address_space       = ["10.2.0.0/16"]
}

resource "azurerm_subnet" "azure-workload" {
  name                 = "vm-subnet"
  resource_group_name  = azurerm_resource_group.azure.name
  virtual_network_name = azurerm_virtual_network.azure.name
  address_prefixes     = ["10.2.1.0/24"]
}

resource "azurerm_subnet" "azure-bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.azure.name
  virtual_network_name = azurerm_virtual_network.azure.name
  address_prefixes     = ["10.2.2.0/24"]
}

resource "azurerm_network_security_group" "azure" {
  name                = "azure-nsg"
  location            = azurerm_resource_group.azure.location
  resource_group_name = azurerm_resource_group.azure.name
}

resource "azurerm_subnet_network_security_group_association" "azure-nsg-workload-subnet" {
  subnet_id                 = azurerm_subnet.azure-workload.id
  network_security_group_id = azurerm_network_security_group.azure.id
}

resource "azurerm_public_ip" "azure-bastion" {
  name                = "AzureBastion-pip"
  location            = azurerm_resource_group.azure.location
  resource_group_name = azurerm_resource_group.azure.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "azure" {
  name                = "azure-bastion"
  sku                 = "Basic"
  location            = azurerm_resource_group.azure.location
  resource_group_name = azurerm_resource_group.azure.name
  ip_configuration {
    name                 = "azure-bastion-configuration"
    subnet_id            = azurerm_subnet.azure-bastion.id
    public_ip_address_id = azurerm_public_ip.azure-bastion.id
  }
}
