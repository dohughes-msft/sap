# ARM templates for networking
## Introduction
With the templates in this folder you can deploy various Azure networking scenarios for demos or production.

|    | Template | Use |
| -- | ----------- | ----------- |
| 1. | `hub_spoke_fw.json` | Deploy a hub VNET with two spokes and an Azure Firewall |
| 2. | `nsg_asg_demo.json` | Deploy a VNET with application and database subnets and a single VM in each |
| 3. | `vnet_nsg.json` | Deploy a VNET with application and database subnets and a single NSG |

## 1. Spoke-hub-spoke with Firewall

## 2. Demo of NSG/ASG

This template will provision:

* 1 VNET with 2 subnets (app and DB)
* 3 NSGs (app, DB, all)
* 2 ASGs (app, DB)
* 2 VMs (app VM, DB VM)       

To listen on a port:

`nc -l -k 30015`

To test connection:

`nc -vz $HOSTNAME $PORT`

## 3. Simple VNET with 2 subnets and a single NSG