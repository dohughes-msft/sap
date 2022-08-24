variable "admin_password" {
  type = string
  sensitive = true
}

variable "vmsize" {
  type = string
  default = "e20"  
}

variable "prefix" {
  type = string
  default = "sapvm"
}

variable "vmcount" {
  type = number
  default = 1
}
