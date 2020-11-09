# Scenario - HANA scale-out system with 3 nodes (2 workers & 1 standby)
## Introduction
[This simple ARM template](hana_scaleout_3node_with_anf.json) will deploy 3 VMs along with Azure NetApp Files storage for a scale-out HANA system.

This is good for a technical proof of concept but will not have the performance charactaristics of a true HANA system due to the more cost-efficient VMs and storage used.

## Prerequisites
* An existing virtual network with subnets for ANF (including delegation) and the database servers. Edit the template variables to have the correct values.

Use Azure Bastion or a jump server to access the VMs.

## Filesystems
Two local data disks are added to each node for /usr/sap and /hana/backup.

The following filesystems are created in ANF and should be mounted on all nodes as follows:

| ANF volume | Mount point |
| ---- | ---- | 
| /sap-hn1-hana-data-node1 | /hana/data/HN1/mnt00001 |
| /sap-hn1-hana-data-node2 | /hana/data/HN1/mnt00002 |
| /sap-hn1-hana-log-node1 | /hana/log/HN1/mnt00001 |
| /sap-hn1-hana-log-node2 | /hana/log/HN1/mnt00002 |
| /sap-hn1-hana-shared | /hana/shared/HN1 |