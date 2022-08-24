resource "azurerm_virtual_network" "sap-spoke2-ne-vnet" {
  name                = "sap-spoke2-ne-vnet"
  location            = azurerm_resource_group.connectivity-ne-rg1.location
  resource_group_name = azurerm_resource_group.connectivity-ne-rg1.name
  address_space       = ["10.2.0.0/16"]
  dns_servers         = ["10.0.0.5", "10.0.0.6"]
}

resource "azurerm_subnet" "sap-spoke2-ne-vnet-db-subnet" {
  name                 = "db-subnet"
  resource_group_name  = azurerm_resource_group.connectivity-ne-rg1.name
  virtual_network_name = azurerm_virtual_network.sap-spoke2-ne-vnet.name
  address_prefixes     = ["10.2.0.0/24"]
}

resource "azurerm_subnet" "sap-spoke2-ne-vnet-app-subnet" {
  name                 = "app-subnet"
  resource_group_name  = azurerm_resource_group.connectivity-ne-rg1.name
  virtual_network_name = azurerm_virtual_network.sap-spoke2-ne-vnet.name
  address_prefixes     = ["10.2.1.0/24"]
}

resource "azurerm_subnet" "sap-spoke2-ne-vnet-web-subnet" {
  name                 = "web-subnet"
  resource_group_name  = azurerm_resource_group.connectivity-ne-rg1.name
  virtual_network_name = azurerm_virtual_network.sap-spoke2-ne-vnet.name
  address_prefixes     = ["10.2.2.0/24"]
}

resource "azurerm_subnet" "sap-spoke2-ne-vnet-anf-subnet" {
  name                 = "anf-subnet"
  resource_group_name  = azurerm_resource_group.connectivity-ne-rg1.name
  virtual_network_name = azurerm_virtual_network.sap-spoke2-ne-vnet.name
  address_prefixes     = ["10.2.10.0/24"]
  delegation {
    name = "anf-delegation"
    service_delegation {
      name = "Microsoft.Netapp/volumes"
      actions = [
        "Microsoft.Network/networkinterfaces/*",
        "Microsoft.Network/virtualNetworks/subnets/join/action"
      ]
    }
  }
}

output "spoke2_db_subnet_id" {
  value = azurerm_subnet.sap-spoke2-ne-vnet-db-subnet.id
}

output "spoke2_app_subnet_id" {
  value = azurerm_subnet.sap-spoke2-ne-vnet-app-subnet.id
}

output "spoke2_web_subnet_id" {
  value = azurerm_subnet.sap-spoke2-ne-vnet-web-subnet.id
}

output "spoke2_anf_subnet_id" {
  value = azurerm_subnet.sap-spoke2-ne-vnet-anf-subnet.id
}
