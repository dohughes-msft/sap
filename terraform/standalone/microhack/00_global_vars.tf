variable "location" {
  type = string
  description = "Azure region for deployment"
}

variable "admin_username" {
  type = string
  description = "The administrator username for virtual machines"
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
  description = "The administrator password for virtual machines"
}

variable "global_label" {
  type = string
  description = "A unique label for this installation"
}

variable "group_label" {
  type = string
  description = "A unique label so this lab can be run in parallel"
}

variable "workload_host_size" {
  type = string
  description = "The size (Azure SKU) of the workload hosts"
}

variable "migration_host_size" {
  type = string
  description = "The size (Azure SKU) of the hosts used for migration and discovery"
}
