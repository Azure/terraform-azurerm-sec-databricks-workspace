provider "azurerm" {
  version = "~>2.3"
  features {}
}

locals {
  unique_name_stub = substr(module.naming.unique-seed, 0, 5)
}

module "naming" {
  source = "git::https://github.com/Azure/terraform-azurerm-naming"
}

resource "azurerm_resource_group" "test_group" {
  name     = "${module.naming.resource_group.slug}-${module.naming.databricks_workspace.slug}-min-test-${local.unique_name_stub}"
  location = "uksouth"
}

resource "azurerm_log_analytics_workspace" "test_la" {
  name                = "${module.naming.resource_group.slug}-${module.naming.log_analytics_workspace.slug}-min-test-${local.unique_name_stub}"
  location            = azurerm_resource_group.test_group.location
  resource_group_name = azurerm_resource_group.test_group.name
  sku                 = "PerGB2018"
}

resource "azurerm_storage_account" "test_sa" {
  name                     = module.naming.storage_account.name_unique
  resource_group_name      = azurerm_resource_group.test_group.name
  location                 = azurerm_resource_group.test_group.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

module "terraform-azurerm-databricks-workspace" {
  source                              = "../../"
  resource_group_name                 = azurerm_resource_group.test_group.name
  log_analytics_resource_group_name   = azurerm_log_analytics_workspace.test_la.resource_group_name
  log_analytics_name                  = azurerm_log_analytics_workspace.test_la.name
  storage_account_name                = azurerm_storage_account.test_sa.name
  storage_account_resource_group_name = azurerm_storage_account.test_sa.resource_group_name
}
