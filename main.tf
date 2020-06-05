provider "azurerm" {
  version = "~> 2.3"
  features {}
}

locals {
  rg_name     = data.azurerm_resource_group.main.name
  rg_location = data.azurerm_resource_group.main.location
  db_ws_sku   = var.databricks_workspace_sku
  la_ws_id    = data.azurerm_log_analytics_workspace.main.id
  storage_id  = data.azurerm_storage_account.main.id
}

module "azurerm_naming" {
  source = "git@github.com:Azure/terraform-azurerm-naming"
  prefix = var.prefix
  suffix = var.suffix
}

resource "azurerm_databricks_workspace" "main" {
  name                = module.azurerm_naming.databricks_workspace.name_unique
  resource_group_name = local.rg_name
  location            = local.rg_location
  sku                 = local.db_ws_sku
}

resource "null_resource" "main" {
  triggers = {
    log_analytics_id   = local.la_ws_id
    storage_account_id = local.storage_id
  }
  provisioner "local-exec" {
    command = "${var.diagnostics_script_path} ${local.rg_name} ${local.la_ws_id} ${local.storage_id} ${azurerm_databricks_workspace.main.id}"
  }
}
