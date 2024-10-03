# Do not put this in .tfvars - provide it on the command line or export it as an
# environment variable before starting Terraform
# For example: 
# terraform apply -var="admin_password=abcd1234"
# or 
# export TF_VAR_admin_password='xxxxxxxx'

variable "location" {
  type = string
  description = "The Azure region in which the resources will be deployed"
}

variable "vpn_shared_key" {
  type = string
  description = "Shared key for the VPN connections"
}
