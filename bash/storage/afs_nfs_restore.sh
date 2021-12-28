#!/bin/bash

AZCOPY=azcopy                                 # Path to azcopy
SHARENAME=/sapmnt/SID/restore                 # NFS share/folder to restore to
SANAME=sapnfsbackup                           # Storage account name
SACONT=sid                                    # Container name
SAFOLDER=sapmnt                               # Folder name

# It is better to define the SAS as an environment variable
#BLOBSAS="?sp=racwdl--------------"

METADATA=metadata.sav

# Create the target if it does not exist
mkdir -p $SHARENAME

# Restore files
$AZCOPY sync "https://${SANAME}.blob.core.windows.net/${SACONT}/${SAFOLDER}${BLOBSAS}" "$SHARENAME" --recursive=true --delete-destination=true

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