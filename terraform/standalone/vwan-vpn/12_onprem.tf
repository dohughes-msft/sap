# Some resources need to be deployed in a second stage, when the public IP and BGP
# peer IPs of the vWAN VPN gateway are known.

# After running the first "terraform apply", go to the VPN gateway of the secure vWAN hub
# and get the public IP addresses and the BGP peer addresses. Populate the variables below,
# set "fire_stage_two" to true and re-apply.

locals {
  primary_public_ip   = ""
  primary_bgp_ip      = ""
  secondary_public_ip = ""
  secondary_bgp_ip    = ""
  fire_stage_two      = false # set to true and re-apply once the variables above are populated
}

resource "azurerm_virtual_network" "onprem" {
  name                = "contoso-onprem-vnet"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = ["192.168.0.0/16"]
}

resource "azurerm_subnet" "onprem-workload" {
  name                 = "onprem-workload"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.onprem.name
  address_prefixes     = ["192.168.0.0/24"]
}

resource "azurerm_subnet" "onprem-gateway" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.onprem.name
  address_prefixes     = ["192.168.10.0/24"]
}

resource "azurerm_network_security_group" "onprem" {
  name                = "onprem-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet_network_security_group_association" "onprem" {
  subnet_id                 = azurerm_subnet.onprem-workload.id
  network_security_group_id = azurerm_network_security_group.onprem.id
}

resource "azurerm_public_ip" "contoso-dc-vpngw" {
  count               = 2
  name                = "contoso-onprem-vpngw-ip${count.index+1}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
}

resource "azurerm_virtual_network_gateway" "contoso-dc-vpngw" {
  name                = "contoso-onprem-vpngw"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  type                = "Vpn"
  vpn_type            = "RouteBased"

  active_active = true
  sku           = "VpnGw1"
  enable_bgp    = true
  bgp_settings {
    asn = 65514
  }

  ip_configuration {
    name                          = "primary"
    public_ip_address_id          = azurerm_public_ip.contoso-dc-vpngw[0].id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.onprem-gateway.id
  }

  ip_configuration {
    name                          = "secondary"
    public_ip_address_id          = azurerm_public_ip.contoso-dc-vpngw[1].id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.onprem-gateway.id
  }
}

resource "azurerm_local_network_gateway" "vwan-vpn-primary" {
  count               = local.fire_stage_two ? 1 : 0
  name                = "vwan-vpn-primary"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  gateway_address     = local.primary_public_ip
  bgp_settings {
    asn = 65515
    bgp_peering_address = local.primary_bgp_ip
  }
}

resource "azurerm_local_network_gateway" "vwan-vpn-secondary" {
  count               = local.fire_stage_two ? 1 : 0
  name                = "vwan-vpn-secondary"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  gateway_address     = local.secondary_public_ip
  bgp_settings {
    asn = 65515
    bgp_peering_address = local.secondary_bgp_ip
  }
}

resource "azurerm_virtual_network_gateway_connection" "vwan-vpn-primary" {
  count               = local.fire_stage_two ? 1 : 0
  name                = "vwan-vpn-primary"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  type                       = "IPsec"
  enable_bgp                 = true
  virtual_network_gateway_id = azurerm_virtual_network_gateway.contoso-dc-vpngw.id
  local_network_gateway_id   = azurerm_local_network_gateway.vwan-vpn-primary[0].id

  shared_key = var.vpn_shared_key
}

resource "azurerm_virtual_network_gateway_connection" "vwan-vpn-secondary" {
  count               = local.fire_stage_two ? 1 : 0
  name                = "vwan-vpn-secondary"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  type                       = "IPsec"
  enable_bgp                 = true
  virtual_network_gateway_id = azurerm_virtual_network_gateway.contoso-dc-vpngw.id
  local_network_gateway_id   = azurerm_local_network_gateway.vwan-vpn-secondary[0].id

  shared_key = var.vpn_shared_key
}
