resource "azurerm_resource_group" "sap-northeurope-hn1" {
  name     = "sap-northeurope-hn1-rg1"
  location = "northeurope"
}

module "sap-ne-hn1-dbserver" {
  source = "../modules/sap/dbserver-hana"
  location = azurerm_resource_group.sap-northeurope-hn1.location
  resource_group_name = azurerm_resource_group.sap-northeurope-hn1.name
  sid = "HN1"
  vm_name = "sap-hn1-db"
  vm_count = 2
  subnet_id = "${module.spoke-ne-sap-dev.vnet_resource_id}/subnets/db-subnet"
  ip_address = ["10.1.0.4","10.1.0.5"]
  vm_size = "Standard_E20ds_v5"
  admin_user = "adminuser"
  admin_password = var.admin_password
}

/*
module "sap-ne-hn1-ascsserver" {
  source = "../modules/sap/ascsserver"
  location = azurerm_resource_group.sap-northeurope-hn1.location
  resource_group_name = azurerm_resource_group.sap-northeurope-hn1.name
  sid = "HN1"
  vm_name = "sap-hn1-ascs"
  vm_count = 2
  subnet_id = "${module.spoke-ne-sap-dev.vnet_resource_id}/subnets/app-subnet"
  ip_address = ["10.1.1.4","10.1.1.5"]
  vm_size = "Standard_D4ds_v5"
  admin_user = "adminuser"
  admin_password = var.admin_password
}

module "sap-ne-hn1-appserver" {
  source = "../modules/sap/appserver"
  location = azurerm_resource_group.sap-northeurope-hn1.location
  resource_group_name = azurerm_resource_group.sap-northeurope-hn1.name
  sid = "HN1"
  vm_name = "sap-hn1-app"
  vm_count = 2
  subnet_id = "${module.spoke-ne-sap-dev.vnet_resource_id}/subnets/app-subnet"
  ip_address = ["10.1.1.6","10.1.1.7"]
  vm_size = "Standard_D4ds_v5"
  admin_user = "adminuser"
  admin_password = var.admin_password
}
*/