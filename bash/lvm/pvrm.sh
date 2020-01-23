#!/bin/bash

for i in /dev/disk/azure/scsi1/lun[0-9]; do
  [[ -b $i ]] && pvremove $i && echo $i removed.
done
