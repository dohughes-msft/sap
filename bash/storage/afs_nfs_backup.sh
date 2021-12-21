#!/bin/bash

AZCOPY=/tmp/azcopy_linux_amd64_10.13.0/azcopy
NFSFS=/mnt/nfspremiumtestfs/sapsid1
SANAME=nfsbackup.blob.core.windows.net
SACONT=sapsid1
# It is better to define the SAS as an environment variable
#BLOBSAS="?sp=racwdl--------------"
METADATA=metadata.sav

# Save metadata information
find $NFSFS -printf "%P,%u,%g,%m,%l\n" | tail -n +2 > /tmp/$METADATA
mv /tmp/$METADATA $NFSFS

# Take the backup
$AZCOPY sync "$NFSFS" "https://${SANAME}/${SACONT}${BLOBSAS}" --recursive=true --delete-destination=true

# Remove the metadata from the filesystem
rm $NFSFS/$METADATA