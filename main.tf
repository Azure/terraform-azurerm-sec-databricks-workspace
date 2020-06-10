provider "azurerm" {
  version = "~> 2.3"
  features {}
}

resource "null_resource" "module_depends_on" {
  triggers = {
    value = "${length(var.module_depends_on)}"
  }
}

locals {
  resource_group_name        = data.azurerm_resource_group.main.name
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.main.id
  storage_account_id         = data.azurerm_storage_account.main.id
}

module "azurerm_naming" {
  source = "git::https://github.com/Azure/terraform-azurerm-naming"
  prefix = var.prefix
  suffix = var.suffix
}

resource "azurerm_databricks_workspace" "main" {
  name                = module.azurerm_naming.databricks_workspace.name_unique
  resource_group_name = local.resource_group_name
  location            = data.azurerm_resource_group.main.location
  sku                 = var.databricks_workspace_sku
}

resource "null_resource" "main" {
  triggers = {
    log_analytics_id   = local.log_analytics_workspace_id
    storage_account_id = local.storage_account_id
  }
  provisioner "local-exec" {
    command = "${var.diagnostics_script_path} ${local.resource_group_name} ${local.log_analytics_workspace_id} ${local.storage_account_id} ${azurerm_databricks_workspace.main.id}"
  }
}
