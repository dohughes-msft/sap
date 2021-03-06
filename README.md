# ARM templates for SAP
With the Azure Resource Manager templates below you can deploy Azure infrastructure for various types of SAP systems. As far as possible the resource names like hostname are calculated from the SAP system ID. You can adapt the variables within the templates to your own naming convention.

## 1. Landing zone (optional)
### Deploy a virtual network, 2 subnets, a single network security group, and a storage account for diagnostics
[![Deploy to Azure](https://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fdohughes-msft%2Fsap%2Fmaster%2Farm%2Fnetwork%2Fvnet_nsg.json)

## 2. Azure NetApp Files (optional)
### Deploy an Azure NetApp Files account and a capacity pool, if you want to use ANF for shared filesystems like /sapmnt
[![Deploy to Azure](https://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fdohughes-msft%2Fsap%2Fmaster%2Farm%2Fanf%2Fanf.json)

## 3. Application layer
### Deploy NFS, ASCS or application server VMs to Azure (single or multiple)
[![Deploy to Azure](https://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fdohughes-msft%2Fsap%2Fmaster%2Farm%2Fvm%2Fvm_app_multi_singleline.json)

## 4. Database layer
### 4a. Deploy HANA VMs to Azure (single or cluster)
Note: Disk configurations for SAP HANA are based on the Microsoft recommended layouts at:
https://docs.microsoft.com/en-us/azure/virtual-machines/workloads/sap/hana-vm-operations-storage.

[![Deploy to Azure](https://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fdohughes-msft%2Fsap%2Fmaster%2Farm%2Fvm%2Fvm_hana_multi.json)

### 4b. Deploy AnyDB VMs to Azure (single or cluster)
You select the disk sizes for executables, datafiles, and transaction logs.

[![Deploy to Azure](https://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fdohughes-msft%2Fsap%2Fmaster%2Farm%2Fvm%2Fvm_anydb_multi.json)

## Examples
1. For a non-redundant system like sandbox, development, etc. deploy:
    1. one application server VM using template (3)
    2. one HANA or AnyDB VM using template (4a) or (4b)
2. For a fully redundant system like production, deploy:
    1. one ANF account/pool using template (2) or two NFS VMs using template (3)
    2. two ASCS VMs using template (3)
    3. two HANA or AnyDB VMs using template (4a) or (4b)
    4. any number of application server VMs using template (3)