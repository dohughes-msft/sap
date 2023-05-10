resource "azurerm_resource_group" "sap-northeurope-sandbox-rg1" {
  name     = "sap-northeurope-sandbox-rg1"
  location = "northeurope"
}

module "sbxvm_lawtest" {
  source = "../modules/generic/win2019_vm"
  location = azurerm_resource_group.sap-northeurope-sandbox-rg1.location
  resource_group_name = azurerm_resource_group.sap-northeurope-sandbox-rg1.name
  vm_name = "sbxvm-lawtest"
  subnet_id = "${module.spoke-ne-sandbox.vnet_resource_id}/subnets/sbx-subnet"
  ip_address = "10.3.0.4"
  vm_size = "Standard_D4ds_v5"
  storage_sku = "Standard_LRS"
  admin_user = "adminuser"
  admin_password = var.admin_password
}
