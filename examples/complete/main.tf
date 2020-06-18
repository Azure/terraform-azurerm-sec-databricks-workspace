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
  name     = "${module.naming.resource_group.slug}-${module.naming.databricks_workspace.slug}-max-${local.unique_name_stub}"
  location = "uksouth"
}

resource "azurerm_log_analytics_workspace" "test_la" {
  name                = "${module.naming.resource_group.slug}-${module.naming.log_analytics_workspace.slug}-max-${local.unique_name_stub}"
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

resource "azurerm_virtual_network" "test_vnet" {
  name                = module.naming.virtual_network.name_unique
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test_group.location
  resource_group_name = azurerm_resource_group.test_group.name
}

resource "azurerm_subnet" "private_snet" {
  name                 = "${module.naming.subnet.name_unique}-private"
  resource_group_name  = azurerm_resource_group.test_group.name
  virtual_network_name = azurerm_virtual_network.test_vnet.name
  address_prefixes     = ["10.0.1.0/24"]

  delegation {
    name = "databricksprivatermdelegation"

    service_delegation {
      name    = "Microsoft.Databricks/workspaces"
    }
  }
}

resource "azurerm_network_security_group" "private_empty_nsg" {
  name                = "${module.naming.network_security_group.name_unique}-private"
  location            = azurerm_resource_group.test_group.location
  resource_group_name = azurerm_resource_group.test_group.name
}

resource "azurerm_subnet_network_security_group_association" "private_nsg_asso" {
  subnet_id                 = azurerm_subnet.private_snet.id
  network_security_group_id = azurerm_network_security_group.private_empty_nsg.id
}

resource "azurerm_subnet" "public_snet" {
  name                 = "${module.naming.subnet.name_unique}-public"
  resource_group_name  = azurerm_resource_group.test_group.name
  virtual_network_name = azurerm_virtual_network.test_vnet.name
  address_prefixes     = ["10.0.2.0/24"]

  delegation {
    name = "databrickspublicdelegation"

    service_delegation {
      name    = "Microsoft.Databricks/workspaces"
    }
  }
}

resource "azurerm_network_security_group" "public_empty_nsg" {
  name                = "${module.naming.network_security_group.name_unique}-public"
  location            = azurerm_resource_group.test_group.location
  resource_group_name = azurerm_resource_group.test_group.name
}

resource "azurerm_subnet_network_security_group_association" "public_nsg_asso" {
  subnet_id                 = azurerm_subnet.public_snet.id
  network_security_group_id = azurerm_network_security_group.public_empty_nsg.id
}

module "terraform-azurerm-databricks-workspace" {
  source                                          = "../../"
  resource_group_name                             = azurerm_resource_group.test_group.name
  log_analytics_resource_group_name               = azurerm_log_analytics_workspace.test_la.resource_group_name
  log_analytics_name                              = azurerm_log_analytics_workspace.test_la.name
  diagnostics_storage_account_resource_group_name = azurerm_storage_account.test_sa.resource_group_name
  diagnostics_storage_account_name                = azurerm_storage_account.test_sa.name
  databricks_virtual_network_name                 = azurerm_virtual_network.test_vnet.name
  databricks_virtual_network_resource_group_name  = azurerm_resource_group.test_group.name
  databricks_private_subnet_name                  = azurerm_subnet.private_snet.name
  databricks_public_subnet_name                   = azurerm_subnet.public_snet.name
  prefix                                          = [local.unique_name_stub]
  suffix                                          = [local.unique_name_stub]
  databricks_workspace_sku                        = "premium"
  diagnostics_script_path                         = "../../scripts/diagnostics.sh"
  no_public_ip                                    = false
  module_depends_on                               = ["azurerm_subnet.private_snet, azurerm_subnet.public_snet"]
}
