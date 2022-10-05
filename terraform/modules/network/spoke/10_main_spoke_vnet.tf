resource "azurerm_virtual_network" "main" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space
  dns_servers         = var.dns_servers
}

resource "azurerm_subnet" "main" {
  count                = length(var.subnet_names)
  name                 = var.subnet_names[count.index]
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.subnet_ip_ranges[count.index]]
  dynamic "delegation" {
    for_each = var.subnet_delegations[count.index] == "anf" ? [1] : []
    content {
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
}

resource "azurerm_virtual_network_peering" "hub-to-spoke" {
  name                      = format("%s-to-%s", var.hub_vnet_name, var.vnet_name)
  resource_group_name       = var.hub_vnet_resource_group_name
  virtual_network_name      = var.hub_vnet_name
  remote_virtual_network_id = azurerm_virtual_network.main.id
}

resource "azurerm_virtual_network_peering" "spoke-to-hub" {
  name                      = format("%s-to-%s", var.vnet_name, var.hub_vnet_name)
  resource_group_name       = var.resource_group_name
  virtual_network_name      = var.vnet_name
  remote_virtual_network_id = var.hub_vnet_id
  allow_forwarded_traffic = true
}


# resource "azurerm_subnet" "sap-spoke1-ne-vnet-db-subnet" {
#   name                 = "db-subnet"
#   resource_group_name  = azurerm_resource_group.connectivity-ne-rg1.name
#   virtual_network_name = azurerm_virtual_network.sap-spoke1-ne-vnet.name
#   address_prefixes     = ["10.1.0.0/24"]
# }

# resource "azurerm_subnet" "sap-spoke1-ne-vnet-app-subnet" {
#   name                 = "app-subnet"
#   resource_group_name  = azurerm_resource_group.connectivity-ne-rg1.name
#   virtual_network_name = azurerm_virtual_network.sap-spoke1-ne-vnet.name
#   address_prefixes     = ["10.1.1.0/24"]
# }

# resource "azurerm_subnet" "sap-spoke1-ne-vnet-web-subnet" {
#   name                 = "web-subnet"
#   resource_group_name  = azurerm_resource_group.connectivity-ne-rg1.name
#   virtual_network_name = azurerm_virtual_network.sap-spoke1-ne-vnet.name
#   address_prefixes     = ["10.1.2.0/24"]
# }

# resource "azurerm_subnet" "sap-spoke1-ne-vnet-anf-subnet" {
#   name                 = "anf-subnet"
#   resource_group_name  = azurerm_resource_group.connectivity-ne-rg1.name
#   virtual_network_name = azurerm_virtual_network.sap-spoke1-ne-vnet.name
#   address_prefixes     = ["10.1.10.0/24"]
#   delegation {
#     name = "anf-delegation"
#     service_delegation {
#       name = "Microsoft.Netapp/volumes"
#       actions = [
#         "Microsoft.Network/networkinterfaces/*",
#         "Microsoft.Network/virtualNetworks/subnets/join/action"
#       ]
#     }
#   }
# }

# output "spoke1_db_subnet_id" {
#   value = azurerm_subnet.sap-spoke1-ne-vnet-db-subnet.id
# }

# output "spoke1_app_subnet_id" {
#   value = azurerm_subnet.sap-spoke1-ne-vnet-app-subnet.id
# }

# output "spoke1_web_subnet_id" {
#   value = azurerm_subnet.sap-spoke1-ne-vnet-web-subnet.id
# }

# output "spoke1_anf_subnet_id" {
#   value = azurerm_subnet.sap-spoke1-ne-vnet-anf-subnet.id
# }
