resource "azurerm_virtual_network" "hub-ne-vnet" {
  name                = "hub-ne-vnet"
  location            = azurerm_resource_group.connectivity-ne-rg1.location
  resource_group_name = azurerm_resource_group.connectivity-ne-rg1.name
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["10.0.0.5", "10.0.0.6"]
}

resource "azurerm_subnet" "hub-ne-vnet-management-subnet" {
  name                 = "management-subnet"
  resource_group_name  = azurerm_resource_group.connectivity-ne-rg1.name
  virtual_network_name = azurerm_virtual_network.hub-ne-vnet.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "hub-ne-vnet-AzureFirewallSubnet" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.connectivity-ne-rg1.name
  virtual_network_name = azurerm_virtual_network.hub-ne-vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "hub-ne-vnet-AzureBastionSubnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.connectivity-ne-rg1.name
  virtual_network_name = azurerm_virtual_network.hub-ne-vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "hub-ne-vnet-firewall-subnet" {
  name                 = "firewall-subnet"
  resource_group_name  = azurerm_resource_group.connectivity-ne-rg1.name
  virtual_network_name = azurerm_virtual_network.hub-ne-vnet.name
  address_prefixes     = ["10.0.3.0/24"]
}

output "mgmt_subnet_id" {
  value = azurerm_subnet.hub-ne-vnet-management-subnet.id
}
