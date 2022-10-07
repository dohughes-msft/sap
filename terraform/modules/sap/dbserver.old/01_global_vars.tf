variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "admin_password" {
  type = string
  sensitive = true
}

variable "prefix" {
  type = string
  default = "sapvm"
}

variable "vmcount" {
  type = number
  default = 1
}

variable "subnet_id" {
  type = string
}

variable "ip_address" {
  type = string
}

variable "vm_size" {
  type = string
  default = "Standard_D4ds_v5"
}

variable "admin_user" {
  type = string
  default = "adminuser"
}

variable "admin_password" {
  type = string
}
