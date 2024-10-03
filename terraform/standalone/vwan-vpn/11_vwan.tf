resource "azurerm_virtual_wan" "main" {
  name                = "contoso-vwan"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
}

resource "azurerm_virtual_hub" "main" {
  name                = "contoso-vhub1"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  virtual_wan_id      = azurerm_virtual_wan.main.id
  address_prefix      = "10.0.0.0/24"
}

resource "azurerm_vpn_gateway" "main" {
  name                = "contoso-vpngw1"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  virtual_hub_id      = azurerm_virtual_hub.main.id
}

resource "azurerm_vpn_site" "contoso-dc" {
  name                = "contoso-dc"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  virtual_wan_id      = azurerm_virtual_wan.main.id

  link {
    name              = "primary"
    provider_name     = "Contoso"
    ip_address        = azurerm_public_ip.contoso-dc-vpngw[0].ip_address
    bgp {
      asn             = azurerm_virtual_network_gateway.contoso-dc-vpngw.bgp_settings[0].asn
      peering_address = azurerm_virtual_network_gateway.contoso-dc-vpngw.bgp_settings[0].peering_addresses[0].default_addresses[0]
    }
  }

  link {
    name              = "secondary"
    provider_name     = "Contoso"
    ip_address        = azurerm_public_ip.contoso-dc-vpngw[1].ip_address
    bgp {
      asn             = azurerm_virtual_network_gateway.contoso-dc-vpngw.bgp_settings[0].asn
      peering_address = azurerm_virtual_network_gateway.contoso-dc-vpngw.bgp_settings[0].peering_addresses[1].default_addresses[0]
    }
  }
}

resource "azurerm_vpn_gateway_connection" "contoso-dc" {
  name               = "contoso-dc"
  vpn_gateway_id     = azurerm_vpn_gateway.main.id
  remote_vpn_site_id = azurerm_vpn_site.contoso-dc.id

  vpn_link {
    name             = "primary"
    vpn_site_link_id = azurerm_vpn_site.contoso-dc.link[0].id
    bgp_enabled        = true
    bandwidth_mbps     = 50
    shared_key         = var.vpn_shared_key
  }

  vpn_link {
    name             = "secondary"
    vpn_site_link_id = azurerm_vpn_site.contoso-dc.link[1].id
    bgp_enabled        = true
    bandwidth_mbps     = 50
    shared_key         = var.vpn_shared_key
  }
}