resource "azurerm_log_analytics_workspace" "law-ne-azure" {
  name                = "azure-platform-law"
  location            = azurerm_resource_group.management-northeurope.location
  resource_group_name = azurerm_resource_group.management-northeurope.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}
