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
}

output "vnet_resource_id" {
  value = azurerm_virtual_network.main.id
}

#output "mgmt_subnet_id" {
#  value = azurerm_subnet.hub-ne-vnet-management-subnet.id
#}

#output "vmfw_subnet_id" {
#  value = azurerm_subnet.hub-ne-vnet-firewall-subnet.id
#}
