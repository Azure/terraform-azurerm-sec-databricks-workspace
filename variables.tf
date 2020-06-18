# Required variables
variable "resource_group_name" {
  type        = string
  description = "The name of the Azure Resource Group to deploy the Databricks workspace to."
}

variable "log_analytics_name" {
  type        = string
  description = "The name of a pre-existing log analytics workspace to stream logs to."
}

variable "log_analytics_resource_group_name" {
  type        = string
  description = "The name of a pre-existing resource group containing the desired log analytics workspace to stream logs to."
}

variable "diagnostics_storage_account_name" {
  type        = string
  description = "The name of a pre-existing storage account to archive logs to."
}

variable "diagnostics_storage_account_resource_group_name" {
  type        = string
  description = "The name of a pre-existing resource group containing the desired storage account to archive logs to."
}

variable "databricks_virtual_network_name" {
  type        = string
  description = "The name of a pre-existing virtual network to provision the Databricks Workspace to."
}

variable "databricks_virtual_network_resource_group_name" {
  type        = string 
  description = "The name of the resource group in which the databricks virtual network resides in."
}

variable "databricks_private_subnet_name" {
  type        = string
  description = "The name of the private Databricks sub net."
}

variable "databricks_public_subnet_name" {
  type        = string
  description = "The name of the public Databricks sub net."
}

# Optional variables
variable "prefix" {
  type        = list(string)
  description = "Components of a naming prefix to be used in the creation of unique names for Azure resources."
  default     = []
}

variable "suffix" {
  type        = list(string)
  description = "Components of a naming suffix to be used in the creation of unique names for Azure resources."
  default     = []
}

variable "databricks_workspace_sku" {
  type        = string
  description = "The SKU of Databricks workspace to deploy. The choices are between standard and premium."
  default     = "premium"
}

variable "diagnostics_script_path" {
  type        = string
  description = "Path to a local script to execute for Databricks diagnostic settings (audit log) setup."
  default     = ""
}

variable "no_public_ip" {
  type        = bool
  description = "A boolean determining whether or not to initialise the Azure Databricks Workspace with a public IP address."
  #NOTE: Default to false here as not every Azure Subscription is by default capable of instantiating Databricks Workspaces with no public IP address. 
  default     = false
}

variable "module_depends_on" {
  default = [""]
}
