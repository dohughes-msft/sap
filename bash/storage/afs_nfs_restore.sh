#!/bin/bash

AZCOPY=/tmp/azcopy_linux_amd64_10.13.0/azcopy
NFSFS=/mnt/nfspremiumtestfs/sapsid1/restore
METADATA=metadata.sav
SANAME=nfsbackup.blob.core.windows.net
SACONT=sapsid1
# It is better to define the SAS as an environment variable
#BLOBSAS="?sp=racwdl--------------"

# Create the target if it does not exist
mkdir -p $NFSFS

# Restore files
$AZCOPY sync "https://${SANAME}/${SACONT}${BLOBSAS}" "$NFSFS" --recursive=true --delete-destination=true

# Restore permissions
cd $NFSFS

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