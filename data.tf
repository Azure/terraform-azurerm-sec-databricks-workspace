data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

data "azurerm_log_analytics_workspace" "main" {
  name                = var.log_analytics_name
  resource_group_name = var.log_analytics_resource_group_name
}

data "azurerm_storage_account" "main" {
  name                = var.storage_account_name
  resource_group_name = var.storage_account_resource_group_name
}
