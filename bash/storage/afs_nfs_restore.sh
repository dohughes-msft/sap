#!/bin/bash

AZCOPY=azcopy                                 # Path to azcopy
SHARENAME=/sapmnt/SD1/restore                 # NFS share/folder to restore to
SANAME=sapnfs3backup                          # Storage account name
SACONT=sd1                                    # Container name
SAFOLDER=sapmnt                               # Folder name

# It is better to define the SAS as an environment variable
#BLOBSAS="?sp=racwdl--------------"

METADATA=!metadata.sav

# Create the target if it does not exist
mkdir -p $SHARENAME

# Restore files
$AZCOPY sync "https://${SANAME}.blob.core.windows.net/${SACONT}/${SAFOLDER}${BLOBSAS}" "$SHARENAME" --recursive=true --delete-destination=true

# Restore metadata
cd $SHARENAME
NUMFILES=$(wc -l $METADATA | awk {'print $1'})
echo -ne "Restoring metadata...\r"
COUNT=1
PCTINTERVAL=5
PCTDONE=$PCTINTERVAL

while IFS="," read -r TYPE FILENAME OWNER GROUP PERMS LINKTARGET LASTMODTIME || [ -n "$TYPE" ]
do
  #printf '%s\n' "$TYPE $FILENAME $OWNER $GROUP $PERMS $LINKTARGET $LASTMODTIME"
  case $TYPE in
    d|f)      # directory or file
      [[ $TYPE == "d" && ! -e $FILENAME ]] && mkdir $FILENAME
      chown $OWNER:$GROUP $FILENAME
      chmod $PERMS $FILENAME
      touch -d @${LASTMODTIME} $FILENAME
      ;;
    l)        # symlink
      # Using ln will cause the parent directory's timestamp to be updated so we need to save and restore it afterwards
      PARENTDIR=$(dirname $FILENAME)
      PARENTLASTMODTIME=$(stat --printf="%.Y" $PARENTDIR)
      echo $PARENTDIR has $PARENTLASTMODTIME
      ln -f -s $LINKTARGET $FILENAME
      chown -h $OWNER:$GROUP $FILENAME
      touch -h -d @${LASTMODTIME} $FILENAME
      touch -d @${PARENTLASTMODTIME} $PARENTDIR
      ;;
    *)
      echo "Unknown file type encountered in $METADATA."
      ;;
  esac
  COUNT=$((COUNT+1))
  if [[ $(( COUNT * 100 / NUMFILES )) -eq $PCTDONE ]]; then
    echo -ne "Restoring metadata... $PCTDONE percent done.\r"
    PCTDONE=$((PCTDONE+PCTINTERVAL))
  fi
done < $METADATA

echo -ne '\n'
rm $METADATA