# PowerShell scripts
## Introduction
With the PowerShell scripts in this folder you can check that your Azure resources have the required configuration.

| Script | Use |
| ----------- | ----------- |
| `set_disk_storage_sku.ps1` | Change the storage SKU of all disks for VM(s) in a given resource group |
| `show_accnet.ps1` | Show the status of accelerated networking for all NICs |
| `show_asg.ps1` | Show the ASG assignments for all VMs |
| `show_diskcaching.ps1` | Show the caching and write accelerator settings for all disks |
| `show_nsg_nic.ps1` | Show the NSG assignments for all NICs |
| `show_nsg_subnet.ps1` | Show the NSG assignments for all subnets |
| `show_ppg_avset.ps1` | Show the PPG assignments for all AvSets |
| `show_ppg_vm.ps1` | Show the PPG assignments for all VMs |
| `show_quotas.ps1` | Show quota current usage and limits for given subscriptions |
| `show_suse_vm_cores.ps1` | Show the number of cores per VM and how many SUSE licenses are needed |

## Calling syntax
Most scripts take only a boolean parameter `-allSubs`. Without this parameter, only the current subscription is in scope. With this parameter, all subscriptions are in scope.

## Example - Show the accelerated networking status of all VMs
~~~~
.\show_accnet.ps1
~~~~

This will produce the output:

~~~~
SubName                NICName            VMName        EnableAcceleratedNetworking
-------                -------            ------        ---------------------------
Don's Azure Playground sapvm1620          sapvm1                              False
Don's Azure Playground sap-nh1-app1-nic1  sap-nh1-app1                         True
Don's Azure Playground sap-nh1-app2-nic1  sap-nh1-app2                         True
Don's Azure Playground sap-nh1-ascs1-nic1 sap-nh1-ascs1                        True
Don's Azure Playground sap-nh1-ascs2-nic1 sap-nh1-ascs2                        True
Don's Azure Playground sap-nh1-db1-nic1   sap-nh1-db1                          True
Don's Azure Playground sap-nh1-db2-nic1   sap-nh1-db2                          True
Don's Azure Playground sap-nh1-nfs1-nic1  sap-nh1-nfs1                         True
Don's Azure Playground sap-nh1-nfs2-nic1  sap-nh1-nfs2                         True
Don's Azure Playground sap-nh1-sbd-nic1   sap-nh1-sbd                          True
Don's Azure Playground sapvm2VMNic        sapvm2                              False
Don's Azure Playground jumpbox01523       jumpbox01                           False
Don's Azure Playground sap-wd1-app1322    sap-wd1-app1                         True
~~~~
