resource "azurerm_virtual_network_peering" "hub-to-spoke1-ne" {
  name                      = "hub-to-spoke1-ne"
  resource_group_name       = azurerm_resource_group.connectivity-ne-rg1.name
  virtual_network_name      = azurerm_virtual_network.hub-ne-vnet.name
  remote_virtual_network_id = azurerm_virtual_network.sap-spoke1-ne-vnet.id
}

resource "azurerm_virtual_network_peering" "spoke1-to-hub-ne" {
  name                      = "spoke1-to-hub-ne"
  resource_group_name       = azurerm_resource_group.connectivity-ne-rg1.name
  virtual_network_name      = azurerm_virtual_network.sap-spoke1-ne-vnet.name
  remote_virtual_network_id = azurerm_virtual_network.hub-ne-vnet.id
  allow_forwarded_traffic = true
}

resource "azurerm_virtual_network_peering" "hub-to-spoke2-ne" {
  name                      = "hub-to-spoke2-ne"
  resource_group_name       = azurerm_resource_group.connectivity-ne-rg1.name
  virtual_network_name      = azurerm_virtual_network.hub-ne-vnet.name
  remote_virtual_network_id = azurerm_virtual_network.sap-spoke2-ne-vnet.id
}

resource "azurerm_virtual_network_peering" "spoke2-to-hub-ne" {
  name                      = "spoke2-to-hub-ne"
  resource_group_name       = azurerm_resource_group.connectivity-ne-rg1.name
  virtual_network_name      = azurerm_virtual_network.sap-spoke2-ne-vnet.name
  remote_virtual_network_id = azurerm_virtual_network.hub-ne-vnet.id
  allow_forwarded_traffic = true
}
