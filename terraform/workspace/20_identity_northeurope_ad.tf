resource "azurerm_resource_group" "identity-northeurope" {
  name     = "identity-northeurope-rg1"
  location = "northeurope"
}

module "activedirectory-northeurope-vm1" {
  source = "../modules/identity/activedirectory"
  location = "northeurope"
  resource_group_name = azurerm_resource_group.identity-northeurope.name
  vm_name = "advm1"
  subnet_id = "${module.hub-ne-vnet.vnet_resource_id}/subnets/management-subnet"
  ip_address = "10.0.0.5"
  admin_user = "adminuser"
  admin_password = var.admin_password
}

module "activedirectory-northeurope-vm2" {
  source = "../modules/identity/activedirectory"
  location = "northeurope"
  resource_group_name = azurerm_resource_group.identity-northeurope.name
  vm_name = "advm2"
  subnet_id = "${module.hub-ne-vnet.vnet_resource_id}/subnets/management-subnet"
  ip_address = "10.0.0.6"
  admin_user = "adminuser"
  admin_password = var.admin_password
}
