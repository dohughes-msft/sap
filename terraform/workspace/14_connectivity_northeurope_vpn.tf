resource "azurerm_public_ip" "onprem-ne-vpn-pip" {
  name                = "onprem-ne-vpn-pip"
  location            = azurerm_resource_group.onprem-northeurope.location
  resource_group_name = azurerm_resource_group.onprem-northeurope.name
  allocation_method = "Dynamic"
}

resource "azurerm_public_ip" "azure-ne-vpn-pip" {
  name                = "azure-ne-vpn-pip"
  location            = azurerm_resource_group.connectivity-northeurope.location
  resource_group_name = azurerm_resource_group.connectivity-northeurope.name
  allocation_method = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "onprem-ne-vpn-gw" {
  name                = "onprem-ne-vpngw"
  location            = azurerm_resource_group.onprem-northeurope.location
  resource_group_name = azurerm_resource_group.onprem-northeurope.name

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = "Basic"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.onprem-ne-vpn-pip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = "${module.onprem-ne-vnet.vnet_resource_id}/subnets/GatewaySubnet"
  }
}
