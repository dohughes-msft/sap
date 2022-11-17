resource "azurerm_resource_group" "sap-northeurope-nw1" {
  name     = "sap-northeurope-nw1-rg1"
  location = "northeurope"
}

module "sap-ne-nw1-dbserver" {
  source = "../modules/sap/dbserver-hana"
  location = azurerm_resource_group.sap-northeurope-nw1.location
  resource_group_name = azurerm_resource_group.sap-northeurope-nw1.name
  sid = "nw1"
  vm_name = "sap-nw1-db"
  vm_count = 1
  subnet_id = "${module.spoke-ne-sap-dev.vnet_resource_id}/subnets/db-subnet"
  ip_address = ["10.1.0.4"]
  vm_size = "Standard_E20ds_v5"
  admin_user = "adminuser"
  admin_password = var.admin_password
}

module "sap-ne-nw1-appserver" {
  source = "../modules/sap/appserver"
  location = azurerm_resource_group.sap-northeurope-nw1.location
  resource_group_name = azurerm_resource_group.sap-northeurope-nw1.name
  sid = "nw1"
  vm_name = "sap-nw1-app"
  vm_count = 1
  subnet_id = "${module.spoke-ne-sap-dev.vnet_resource_id}/subnets/app-subnet"
  ip_address = ["10.1.1.6"]
  vm_size = "Standard_E8ds_v5"
  admin_user = "adminuser"
  admin_password = var.admin_password
}
