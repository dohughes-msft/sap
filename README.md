# ARM templates for SAP
Templates for deployment of SAP systems. Before starting, you need to create:

* Resource group in the location where the resources will be deployed
* Virtual network, subnet, and resource group containing them (use the first script below)
* Network security group (if used), and resource group containing it (use the first script below)

Disk configurations for SAP HANA are based on the Microsoft recommended layouts at:

https://docs.microsoft.com/en-us/azure/virtual-machines/workloads/sap/hana-vm-operations-storage

# Deploy a virtual network, subnets and a single network security group
[![Deploy to Azure](https://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fdohughes-msft%2Fsap%2Fmaster%2Farm%2Fnetwork%2Fvnet_nsg.json)

# Deploy HANA VMs to Azure (single or cluster)
[![Deploy to Azure](https://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fdohughes-msft%2Fsap%2Fmaster%2Farm%2Fvm%2Fvm_hana_multi.json)

# Deploy NFS, ASCS or application server VMs to Azure (single or multiple)
[![Deploy to Azure](https://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fdohughes-msft%2Fsap%2Fmaster%2Farm%2Fvm%2Fvm_app_multi.json)
