resource "azurerm_resource_group" "onprem-northeurope" {
  name     = "onprem-northeurope-rg1"
  location = "northeurope"
}

module "onprem-ne-vnet" {
  source = "../modules/network/hub"
  location = "northeurope"
  resource_group_name = azurerm_resource_group.onprem-northeurope.name
  vnet_name = "onprem-ne-vnet"
  address_space = ["10.10.0.0/16"]
  subnet_names = ["onprem-workload-subnet","GatewaySubnet"]
  subnet_ip_ranges = ["10.10.0.0/24","10.10.10.0/24"]
  dns_servers = []
}
/*
module "onprem-ne-hypervhost1" {
  source = "../modules/generic/win2019_vm_dualnic"
  location = "northeurope"
  resource_group_name = azurerm_resource_group.onprem-northeurope.name
  vm_name = "hypervhost1"
  subnet_id = "${module.onprem-ne-vnet.vnet_resource_id}/subnets/onprem-workload-subnet"
  ip_address = "10.10.0.4"
  subnet_id_2 = "${module.onprem-ne-vnet.vnet_resource_id}/subnets/hyperv-subnet"
  ip_address_2 = "10.10.1.4"
  vm_size = "Standard_E8ds_v5"
  storage_sku = "Standard_LRS"
  admin_user = "adminuser"
  admin_password = var.admin_password
}
*/
