# ARM templates for SAP
With the Azure Resource Manager templates below you can deploy Azure infrastructure for various types of SAP systems. As far as possible the resource names like hostname are calculated from the SAP system ID. You can adapt the variables within the templates to your own naming convention.

## 1. Landing zone
### Deploy a virtual network, 2 subnets and a single network security group
[![Deploy to Azure](https://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fdohughes-msft%2Fsap%2Fmaster%2Farm%2Fnetwork%2Fvnet_nsg.json)

## 2. Application layer
### Deploy NFS, ASCS or application server VMs to Azure (single or multiple)
[![Deploy to Azure](https://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fdohughes-msft%2Fsap%2Fmaster%2Farm%2Fvm%2Fvm_app_multi_singleline.json)

## 3. Database layer
### 3a. Deploy HANA VMs to Azure (single or cluster)
Note: Disk configurations for SAP HANA are based on the Microsoft recommended layouts at:
https://docs.microsoft.com/en-us/azure/virtual-machines/workloads/sap/hana-vm-operations-storage.

[![Deploy to Azure](https://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fdohughes-msft%2Fsap%2Fmaster%2Farm%2Fvm%2Fvm_hana_multi_singleline.json)

### 3b. Deploy AnyDB VMs to Azure (single or cluster)
You select the disk sizes for executables, datafiles, and transaction logs.

[![Deploy to Azure](https://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fdohughes-msft%2Fsap%2Fmaster%2Farm%2Fvm%2Fvm_anydb_multi_singleline.json)

## Examples
1. For a non-redundant system like sandbox, development, etc. deploy:
    1. one application server VM using template (2)
    2. one HANA VM using template (3)
2. For a fully redundant system like production, deploy:
    1. two NFS VMs using template (2)
    2. two ASCS VMs using template (2)
    3. two HANA or AnyDB VMs using template (3a) or (3b)
    4. any number of application server VMs using template (2)