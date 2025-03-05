# Create the simulated on-premises network

locals {
  myid = "dohughes@microsoft.com"
}

resource "azurerm_virtual_network" "onprem" {
  name                = "onprem-vnet"
  location            = azurerm_resource_group.onprem.location
  resource_group_name = azurerm_resource_group.onprem.name
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_subnet" "onprem-workload" {
  name                 = "vm-subnet"
  resource_group_name  = azurerm_resource_group.onprem.name
  virtual_network_name = azurerm_virtual_network.onprem.name
  address_prefixes     = ["10.1.1.0/24"]
}

resource "azurerm_subnet" "onprem-bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.onprem.name
  virtual_network_name = azurerm_virtual_network.onprem.name
  address_prefixes     = ["10.1.2.0/24"]
}

resource "azurerm_network_security_group" "onprem" {
  name                = "onprem-nsg"
  location            = azurerm_resource_group.onprem.location
  resource_group_name = azurerm_resource_group.onprem.name
}

resource "azurerm_network_security_rule" "http" {
  name                        = "AllowHTTP"
  priority                    = 1000
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["80","443"]
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.onprem.name
  network_security_group_name = azurerm_network_security_group.onprem.name
}

resource "azurerm_subnet_network_security_group_association" "onprem-nsg-workload-subnet" {
  subnet_id                 = azurerm_subnet.onprem-workload.id
  network_security_group_id = azurerm_network_security_group.onprem.id
}

resource "azurerm_public_ip" "onprem-bastion" {
  #count = var.use_bastion ? 1 : 0
  name                = "AzureBastion-pip"
  location            = azurerm_resource_group.onprem.location
  resource_group_name = azurerm_resource_group.onprem.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "onprem" {
  #count = var.use_bastion ? 1 : 0
  name                = "onprem-bastion"
  sku                 = "Basic"
  location            = azurerm_resource_group.onprem.location
  resource_group_name = azurerm_resource_group.onprem.name
  ip_configuration {
    name                 = "onprem-bastion-configuration"
    subnet_id            = azurerm_subnet.onprem-bastion.id
    public_ip_address_id = azurerm_public_ip.onprem-bastion.id
  }
}

# Add a key vault
data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "onprem" {
  name                = "${var.global_label}-${var.group_label}-kv"
  location            = azurerm_resource_group.onprem.location
  resource_group_name = azurerm_resource_group.onprem.name
  sku_name            = "standard"
  tenant_id           = data.azurerm_client_config.current.tenant_id
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id
    secret_permissions = [
      "Get", "List", "Set", "Delete", "Recover", "Backup", "Restore", "Purge"
    ]
  }
}

# Add a secret
resource "azurerm_key_vault_secret" "adminpass" {
  name         = "adminpassword"
  value        = var.admin_password
  key_vault_id = azurerm_key_vault.onprem.id
}
