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

variable "storage_account_name" {
  type        = string
  description = "The name of a pre-existing storage account to archive logs to."
}

variable "storage_account_resource_group_name" {
  type        = string
  description = "The name of a pre-existing resource group containing the desired storage account to archive logs to."
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
  default     = "./scripts/diagnostics.sh"
}

variable "module_depends_on" {
  default = [""]
}
