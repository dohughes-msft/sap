variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "sid" {
  type = string
}

variable "vm_name" {
  type = string
  default = "sapvm"
}

variable "vm_count" {
  type = number
  default = 1
}

variable "subnet_id" {
  type = string
}

variable "ip_address" {
  type = list(string)
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
  sensitive = true
}
