variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "vnet_name" {
  type = string
}

variable "address_space" {
  type = list(string)
  default = ["10.0.0.0/16"]
}

variable "subnet_names" {
  type = list(string)
  default = ["default"]
}

variable "subnet_ip_ranges" {
  type = list(string)
  default = ["10.0.0.0/24"]
}

variable "dns_servers" {
  type = list(string)
}
