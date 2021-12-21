#!/bin/bash

AZCOPY=/tmp/azcopy_linux_amd64_10.13.0/azcopy              # Path to azcopy
SHARENAME=/mnt/nfspremiumtestfs/sapsid1/restore            # NFS share/folder to restore to
SANAME=nfsbackup                                           # Storage account name
SACONT=sapsid1                                             # Container name

# It is better to define the SAS as an environment variable
#BLOBSAS="?sp=racwdl--------------"

METADATA=metadata.sav

# Create the target if it does not exist
mkdir -p $SHARENAME

# Restore files
$AZCOPY sync "https://${SANAME}/${SACONT}${BLOBSAS}" "$SHARENAME" --recursive=true --delete-destination=true

# Restore permissions
cd $SHARENAME

while IFS="," read -r FILENAME OWNER GROUP PERMS LINKTARGET || [ -n "$FILENAME" ]
do
  #printf '%s\n' "$FILENAME $OWNER $GROUP $PERMS $LINKTARGET"
  if [[ $LINKTARGET == "" ]]; then
    # It's a file or directory
    chown $OWNER:$GROUP $FILENAME
    chmod $PERMS $FILENAME
  else
    # It's a symlink
    ln -s $LINKTARGET $FILENAME
    chown -h $OWNER:$GROUP $FILENAME
  fi
done < $METADATA

rm $METADATA