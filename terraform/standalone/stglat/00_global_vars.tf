variable "location" {
  type = string
  description = "Azure region for deployment"
}

variable "resource_group_name" {
  type = string
  description = "Resource group name"
}

variable "admin_username" {
  type = string
  description = "The administrator username for the on-premises Hyper-V host"
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

variable "admin_ip_address" {
  type = string
  description = "The IP address or range from which access to the on-premises Hyper-V host is allowed, if not using Bastion"
}

variable "vnet_name" {
  type = string
  description = "The name of the on-premises virtual network"
}

variable "subnet_name" {
  type = string
  description = "The name of the on-premises subnet"
}

variable "nsg_name" {
  type = string
  description = "The name of the on-premises Network Security Group"
}

variable "hostname_prefix" {
  type = string
  description = "Prefix for the VMs"
}

variable "host_size" {
  type = string
  description = "The size (Azure SKU) of the on-premises Hyper-V host"
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

variable "storage_account_prefix" {
  type = string
  description = "A prefix for the name of the storage account for storing replicated VMs. Maximum length 16 characters. Randomly generated characters will be added to the end to ensure uniqueness"
  validation {
    condition     = length(var.storage_account_prefix) <= 16
    error_message = "The length of the storage account prefix must be 16 characters or less"
  }
}