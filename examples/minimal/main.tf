provider "azurerm" {
  version = "~>2.3"
  features {}
}

module "azurerm_naming" {
  source = "git@github.com:Azure/terraform-azurerm-naming"
}

resource "azurerm_resource_group" "test_group" {
  name     = "${module.azurerm_naming.resource_group.slug}-${module.azurerm_naming.databricks_workspace.slug}-minimal-test-${substr(module.azurerm_naming.unique-seed, 0, 6)}"
  location = "uksouth"
}

resource "azurerm_log_analytics_workspace" "test_la" {
  name                = substr(module.azurerm_naming.unique-seed, 0, 6)
  location            = azurerm_resource_group.test_group.location
  resource_group_name = azurerm_resource_group.test_group.name
  sku                 = "PerGB2018"
}

resource "azurerm_storage_account" "test_sa" {
  name                     = substr(module.azurerm_naming.unique-seed, 0, 6)
  resource_group_name      = azurerm_resource_group.test_group.name
  location                 = azurerm_resource_group.test_group.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

module "terraform-azurerm-databricks-workspace" {
  source                  = "../"
  resource_group_name     = azurerm_resource_group.test_group.name
  log_analytics_rg_name   = azurerm_log_analytics_workspace.test_la.resource_group_name
  storage_account_rg_name = azurerm_storage_account.test_sa.resource_group_name
  log_analytics_name      = azurerm_log_analytics_workspace.test_la.name
  storage_account_name    = azurerm_storage_account.test_sa.name
  diagnostics_script_path = "../scripts/diagnostics.sh"
}
