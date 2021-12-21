#!/bin/bash

AZCOPY=/tmp/azcopy_linux_amd64_10.13.0/azcopy              # Path to azcopy
SHARENAME=/mnt/nfspremiumtestfs/sapsid1                    # The NFS share to back up (must be mounted)
SANAME=nfsbackup                                           # Storage account name
SACONT=sapsid1                                             # Container name

# It is better to define the SAS as an environment variable
#BLOBSAS="?sp=racwdl--------------"                        # SAS to access the blob/container

METADATA=metadata.sav

# Save metadata information
find $SHARENAME -printf "%P,%u,%g,%m,%l\n" | tail -n +2 > /tmp/$METADATA
mv /tmp/$METADATA $SHARENAME

# Take the backup
$AZCOPY sync "$SHARENAME" "https://${SANAME}.blob.core.windows.net/${SACONT}${BLOBSAS}" --recursive=true --delete-destination=true

# Remove the metadata from the filesystem
rm $SHARENAME/$METADATA