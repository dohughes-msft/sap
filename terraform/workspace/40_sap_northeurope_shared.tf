resource "azurerm_resource_group" "sap-northeurope-shared" {
  name     = "sap-northeurope-shared-rg1"
  location = "northeurope"
}

module "sap-ne-shared-sapdownload" {
  source = "../modules/sap/genericwin"
  location = azurerm_resource_group.sap-northeurope-shared.location
  resource_group_name = azurerm_resource_group.sap-northeurope-shared.name
  vm_name = "sapdownload"
  vm_count = 1
  subnet_id = "${module.spoke-ne-sap-dev.vnet_resource_id}/subnets/tools-subnet"
  ip_address = ["10.1.3.4"]
  vm_size = "Standard_D4ds_v5"
  admin_user = "adminuser"
  admin_password = var.admin_password
}

resource "azurerm_storage_account" "sapnebackup" {
  name                     = "sapnebackup"
  resource_group_name      = azurerm_resource_group.sap-northeurope-shared.name
  location                 = azurerm_resource_group.sap-northeurope-shared.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "sapnebackup-sapbackup" {
  name                 = "sapbackup"
  storage_account_name = azurerm_storage_account.sapnebackup.name
  quota                = 1000
}