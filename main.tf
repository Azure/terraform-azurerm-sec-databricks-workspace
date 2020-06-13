provider "azurerm" {
  version = "~> 2.3"
  features {}
}

locals {
  resource_group                 = data.azurerm_resource_group.main
  databricks_vnet_id             = data.azurerm_virtual_network.main.id
  databricks_private_snet_name   = data.azurerm_subnet.private.name
  databricks_public_snet_name    = data.azurerm_subnet.public.name
  log_analytics_workspace_id     = data.azurerm_log_analytics_workspace.main.id
  diagnostics_storage_account_id = data.azurerm_storage_account.main.id
}

module "azurerm_naming" {
  source = "git::https://github.com/Azure/terraform-azurerm-naming"
  prefix = var.prefix
  suffix = var.suffix
}

resource "azurerm_databricks_workspace" "main" {
  name                = module.azurerm_naming.databricks_workspace.name_unique
  resource_group_name = local.resource_group.name
  location            = local.resource_group.location
  sku                 = var.databricks_workspace_sku

  custom_parameters {
    virtual_network_id  = local.databricks_vnet_id
    public_subnet_name  = local.databricks_public_snet_name
    private_subnet_name = local.databricks_private_snet_name
  }
}

resource "null_resource" "main" {
  triggers = {
    log_analytics_id               = local.log_analytics_workspace_id
    diagnostics_storage_account_id = local.diagnostics_storage_account_id
  }
  provisioner "local-exec" {
    command = "${var.diagnostics_script_path} ${local.resource_group.name} ${local.log_analytics_workspace_id} ${local.diagnostics_storage_account_id} ${azurerm_databricks_workspace.main.id}"
  }
}

resource "null_resource" "module_depends_on" {
  triggers = {
    value = "${length(var.module_depends_on)}"
  }
}

