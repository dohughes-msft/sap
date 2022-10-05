#!/bin/bash

AZCOPY=azcopy                                 # Path to azcopy
SHARENAME=/sapmnt/SD1/original                # NFS share/folder to back up
SANAME=sapnfs3backup                          # Storage account name
SACONT=sd1                                    # Container name
SAFOLDER=sapmnt                               # Folder name

# It is better to define the SAS as an environment variable
#BLOBSAS="?sp=racwdl--------------"                        # SAS to access the blob/container

METADATA=!metadata.sav

# Save metadata information
mkdir -p /tmp/nfsbackup.$$
find $SHARENAME -printf "%y,%P,%u,%g,%m,%l,%T@\n" | tail -n +2 > /tmp/nfsbackup.$$/$METADATA
mv /tmp/nfsbackup.$$/$METADATA $SHARENAME

# Take the backup
$AZCOPY sync "$SHARENAME" "https://${SANAME}.blob.core.windows.net/${SACONT}/${SAFOLDER}${BLOBSAS}" --recursive=true --delete-destination=true

# Remove the metadata from the filesystem
rm $SHARENAME/$METADATA
rm -rf /tmp/nfsbackup.$$