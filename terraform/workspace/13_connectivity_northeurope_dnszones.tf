resource "azurerm_private_dns_zone" "contoso-com" {
  name                = "contoso.com"
  resource_group_name = azurerm_resource_group.connectivity-northeurope.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "hub-ne-vnet" {
  name                  = "hub-ne-contoso-com"
  resource_group_name   = azurerm_resource_group.connectivity-northeurope.name
  private_dns_zone_name = azurerm_private_dns_zone.contoso-com.name
  virtual_network_id    = module.hub-ne-vnet.vnet_resource_id
  registration_enabled  = true
}

resource "azurerm_private_dns_zone_virtual_network_link" "spoke-ne-sap-dev" {
  name                  = "spoke-ne-sap-dev-contoso-com"
  resource_group_name   = azurerm_resource_group.connectivity-northeurope.name
  private_dns_zone_name = azurerm_private_dns_zone.contoso-com.name
  virtual_network_id    = module.spoke-ne-sap-dev.vnet_resource_id
  registration_enabled  = true
}

resource "azurerm_private_dns_zone_virtual_network_link" "spoke-ne-sap-prd" {
  name                  = "spoke-ne-sap-prd-contoso-com"
  resource_group_name   = azurerm_resource_group.connectivity-northeurope.name
  private_dns_zone_name = azurerm_private_dns_zone.contoso-com.name
  virtual_network_id    = module.spoke-ne-sap-prd.vnet_resource_id
  registration_enabled  = true
}