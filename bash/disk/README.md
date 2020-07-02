# Filesystem automation for SAP systems
## Introduction
With the scripts here you can automate the creation of filesystems for SAP systems. By providing a configuration file that describes the desired state you can finely control which filesystems are created and on which volumes and disks they are located. Filesystems are always striped across the maximum number of disks to achieve the best performance.

## Alternatives
There are main two ways of combining multiple disks into filesystems, LVM and mdadm. Both are robust technologies and while they are broadly equivalent, there are small differences that may make one or the other more suitable to a particular situation.

### 1. Logical Volume Manager aka LVM
LVM makes administration easy. Storage devices (disks) are assigned to volume groups, which are then divided up in to logical volumes, on which you create the filesystems. You can have any number of storage devices underneath, divided among any number of filesystems.

### 2. Software RAID aka mdadm
mdadm is a little less easygoing on the administration side but is generally held to have a slight performance advantage over LVM. Storage devices (disks) are combined into arrays upon which you can create filesystems. Note that if you want to have multiple filesystems on the same array, you need to use LVM to create a volume group on top of the array and then proceed as in the first case.

The one area where mdadm has a clear advantage is when the time comes to add disks to an existing array. With LVM, to increase the size of a striped volume you would need to add the same number of disks again to the volume group. In contrast, with mdadm you can add any number of disks and mdadm will automatically rebalance the stripes across them. After that it is simple to extend the filesystem.

## The scripts

| Alternative | Script |
| ---- | ---- |
| LVM | [`lvm4sap.sh`](lvm4sap.md) |
| mdadm | [`mdadm4sap.sh`](mdadm4sap.md) |
