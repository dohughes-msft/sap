
# variable "disk_configurations" {
#   type = map(map(number))
#   default = {
#     e20 = {
#       datasize = 128
#       datacount = 3
#       logsize = 64
#       logcount = 2
#       sharedsize = 256
#       usrsapsize = 64
#     }
#     e32 = {
#       datasize = 128
#       datacount = 3
#       logsize = 64
#       logcount = 2
#       sharedsize = 256
#       usrsapsize = 64
#     }
#   }
# }

locals {
  disk_config = {
    Standard_E20ds_v5 = {
      datasize = 128
      datacount = 3
      logsize = 64
      logcount = 2
      sharedsize = 256
      usrsapsize = 64
    }
    Standard_E32ds_v5 = {
      datasize = 128
      datacount = 3
      logsize = 64
      logcount = 2
      sharedsize = 256
      usrsapsize = 64
    }
  }
}
