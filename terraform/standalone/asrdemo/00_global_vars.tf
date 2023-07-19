variable "location" {
  type = string
  description = "Azure region for deployment"
}

variable "onprem_resource_group_name" {
  type = string
  description = "Resource group name that will hold the simulated on-premises resources"
}

#variable "azure_resource_group_name" {
#  type = string
#}

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
  description = "The name of the NSG"
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
