#!/bin/bash

for i in /dev/disk/azure/scsi1/lun[0-9]; do
  [[ -b $i ]] && pvcreate $i && echo $i created as a physical volume.
done
