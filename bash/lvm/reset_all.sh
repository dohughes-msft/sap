#!/bin/bash

echo "This script will do the following:"
echo
echo "1. Unmount all XFS filesystems"
echo "2. Delete all LVM volume groups"
echo "3. Delete all physical volumes"
echo
read -p "Press enter to continue or CTRL-C to cancel."

umount -a -t xfs

if ls /etc/fstab.* 1> /dev/null 2>&1; then
    LATEST=$(ls -1 /etc/fstab.* | tail -1)
    cp -p $LATEST /etc/fstab
elif [[ -f /etc/fstab.nodisk ]]; then
    cp -p /etc/fstab.nodisk /etc/fstab
fi

for i in $(vgs -o vg_name --noheadings); do
  vgremove -y $i
done
for i in $(pvs -o pv_name --noheadings); do
  pvremove -y $i
done
