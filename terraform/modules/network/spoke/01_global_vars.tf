variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "vnet_name" {
  type = string
}

variable "address_space" {
  type = list(string)
}

variable "subnet_names" {
  type = list(string)
}

variable "subnet_ip_ranges" {
  type = list(string)
}

variable "subnet_delegations" {
  type = list(string)
}

variable "dns_servers" {
  type = list(string)
}

variable "hub_vnet_resource_group_name" {
  type = string
}

variable "hub_vnet_name" {
  type = string
}

variable "hub_vnet_id" {
  type = string
}
