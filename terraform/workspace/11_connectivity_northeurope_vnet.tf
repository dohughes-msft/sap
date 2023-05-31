module "hub-ne-vnet" {
  source = "../modules/network/hub"
  location = "northeurope"
  resource_group_name = azurerm_resource_group.connectivity-northeurope.name
  vnet_name = "hub-ne-vnet"
  address_space = ["10.0.0.0/16"]
  subnet_names = ["management-subnet","AzureFirewallSubnet","AzureBastionSubnet","firewall-subnet","GatewaySubnet"]
  subnet_ip_ranges = ["10.0.0.0/24","10.0.1.0/24","10.0.2.0/24","10.0.3.0/24","10.0.10.0/24"]
  dns_servers = ["10.0.0.5","10.0.0.6"]
}

module "spoke-ne-sap-dev" {
  source = "../modules/network/spoke"
  location = "northeurope"
  resource_group_name = azurerm_resource_group.connectivity-northeurope.name
  vnet_name = "spoke-ne-sap-dev"
  address_space = ["10.1.0.0/16"]
  subnet_names = ["db-subnet","app-subnet","web-subnet","anf-subnet","tools-subnet"]
  subnet_ip_ranges = ["10.1.0.0/24","10.1.1.0/24","10.1.2.0/24","10.1.10.0/24","10.1.3.0/24"]
  subnet_delegations = ["","","","anf",""]
  dns_servers = ["10.0.0.5","10.0.0.6"]
  hub_vnet_resource_group_name = azurerm_resource_group.connectivity-northeurope.name
  hub_vnet_name = "hub-ne-vnet"
  hub_vnet_id = module.hub-ne-vnet.vnet_resource_id
}

module "spoke-ne-sap-prd" {
  source = "../modules/network/spoke"
  location = "northeurope"
  resource_group_name = azurerm_resource_group.connectivity-northeurope.name
  vnet_name = "spoke-ne-sap-prd"
  address_space = ["10.2.0.0/16"]
  subnet_names = ["db-subnet","app-subnet","web-subnet","anf-subnet"]
  subnet_ip_ranges = ["10.2.0.0/24","10.2.1.0/24","10.2.2.0/24","10.2.10.0/24"]
  subnet_delegations = ["","","","anf"]
  dns_servers = ["10.0.0.5","10.0.0.6"]
  hub_vnet_resource_group_name = azurerm_resource_group.connectivity-northeurope.name
  hub_vnet_name = "hub-ne-vnet"
  hub_vnet_id = module.hub-ne-vnet.vnet_resource_id
}

module "spoke-ne-sandbox" {
  source = "../modules/network/spoke"
  location = "northeurope"
  resource_group_name = azurerm_resource_group.connectivity-northeurope.name
  vnet_name = "spoke-ne-sandbox"
  address_space = ["10.3.0.0/16"]
  subnet_names = ["sbx-subnet","anf-subnet"]
  subnet_ip_ranges = ["10.3.0.0/24","10.3.10.0/24"]
  subnet_delegations = ["","anf"]
  dns_servers = ["10.0.0.5","10.0.0.6"]
  hub_vnet_resource_group_name = azurerm_resource_group.connectivity-northeurope.name
  hub_vnet_name = "hub-ne-vnet"
  hub_vnet_id = module.hub-ne-vnet.vnet_resource_id
}
