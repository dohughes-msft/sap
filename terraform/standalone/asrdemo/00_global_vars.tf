variable "location" {
  type = string
  description = "Azure region for deployment"
}

variable "onprem_resource_group_name" {
  type = string
  description = "Resource group name that will hold the simulated on-premises resources"
}

# Do not put this in .tfvars - provide it on the command line or export it as an
# environment variable before starting Terraform
# For example: 
# terraform apply -var="admin_password=abcd1234"
# or 
# export TF_VAR_admin_password='xxxxxxxx'
variable "admin_password" {
  type = string
  sensitive = true
  description = "The administrator password for the on-premises Hyper-V host"
}

variable "group_label" {
  type = string
  description = "A unique label so this lab can be run in parallel"
}

variable "onprem_vnet_name" {
  type = string
  description = "The name of the on-premises virtual network"
}

variable "onprem_subnet_name" {
  type = string
  description = "The name of the on-premises subnet"
}

variable "onprem_nsg_name" {
  type = string
  description = "The name of the on-premises Network Security Group"
}

variable "hyperv_hostname" {
  type = string
  description = "The name of the on-premises Hyper-V host"
}

variable "hyperv_host_size" {
  type = string
  description = "The size (Azure SKU) of the on-premises Hyper-V host"
}

variable "admin_ip_address" {
  type = string
  description = "The IP address or range from which access to the on-premises Hyper-V host is allowed, if not using Bastion"
}

variable "use_bastion" {
  type = bool
  default = false
  description = "True if an Azure Bastion resource should be deployed, otherwise false"
}

variable "use_public_ip_address" {
  type = bool
  default = true
  description = "True if a public IP address should be assigned to the on-premises Hyper-V host, otherwise false"
}

variable "azure_resource_group_name" {
  type = string
  description = "Resource group name that will hold the Azure resources"
}

variable "azure_vnet_name" {
  type = string
  description = "The name of the Azure virtual network"
}

variable "azure_test_vnet_name" {
  type = string
  description = "The name of the Azure virtual network used for failover testing"
}

variable "azure_subnet_name" {
  type = string
  description = "The name of the Azure subnet"
}

variable "azure_nsg_name" {
  type = string
  description = "The name of the Azure Network Security Group"
}

variable "recovery_vault_name" {
  type = string
  description = "Name of the Recovery Services Vault"
}

variable "storage_account_prefix" {
  type = string
  description = "A prefix for the name of the storage account for storing replicated VMs. Maximum length 16 characters. Randomly generated characters will be added to the end to ensure uniqueness"
  validation {
    condition     = length(var.storage_account_prefix) <= 16
    error_message = "The length of the storage account prefix must be 16 characters or less"
  }
}

variable "failover_public_ip_count" {
  type = number
  description = "Number of public IP addresses to create for failover testing"
}