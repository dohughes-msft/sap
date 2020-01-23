#!/bin/bash
#-------------------------------------------------------------------------
# Filename: mklvfs.sh
# Author: Donovan Hughes
# Info: Script to take a file as input and create LVs and filesystems in the VGs
# Set DEBUG=Y before running the script for debug mode
# Syntax:          mklvfs.sh -s <SID> -t <tablefile>
# Run as:          root
#
# Sample input table:
# volumegroup,logicalvolume,filesystem,sizeMB|all
# SID/sid in the table will be replaced by the given SID
#
# SIDsapvg,lvSIDusrsap,/usr/sap/SID,20480
# SIDsapvg,lvSIDsapmnt,/sapmnt/SID,10240
# SIDsapvg,lvSIDdb2home,/db2/SID,2048
# SIDsapvg,lvSIDdb2inst,/db2/db2sid,10240
# SIDsapvg,lvSIDdb2audit,/db2/SID/db2audit,5120
# SIDsapvg,lvSIDlogarch,/db2/SID/log_archive,10240
# SIDsapvg,lvSIDdb2dump,/db2/SID/db2dump,2048
# SIDlogvg,lvSIDlogdir,/db2/SID/log_dir,all
# SIDdatavg,lvSIDdb2data1,/db2/SID/sapdata1,all
#
# Return codes:
# 0 - Successfully completed whole script
# 1 - Warning occurred
# 2 or higher - Error occurred
# 255 - Incorrect script usage detected. Usage information printed
#-------------------------------------------------------------------------

[[ $DEBUG == 'Y' ]] && set -x

#-------------------------------------------------------------------------
# Functions
#-------------------------------------------------------------------------

function start {
log info Start execution of $SCRIPTFULLNAME
log info $(date)
}

function finish {
log info Stop execution of $SCRIPTFULLNAME
log info $(date)
echo
exit $1
}

function usage {
log info "Please use    $SCRIPTNAME -s <SID> -t <tablefile>"
log info
log info "-s <SID>           : SAP system ID"
log info "-t <tablefile>     : VG-to-LV+FS mapping file"
log info "A mapping file should look like:"
echo
echo "SIDsapvg,lvSIDusrsap,/usr/sap/SID,20480"
echo "SIDsapvg,lvSIDsapmnt,/sapmnt/SID,10240"
echo "SIDsapvg,lvSIDdb2home,/db2/SID,2048"
echo "SIDsapvg,lvSIDdb2inst,/db2/db2sid,10240"
echo "SIDsapvg,lvSIDdb2audit,/db2/SID/db2audit,5120"
echo "SIDsapvg,lvSIDlogarch,/db2/SID/log_archive,10240"
echo "SIDsapvg,lvSIDdb2dump,/db2/SID/db2dump,2048"
echo "SIDlogvg,lvSIDlogdir,/db2/SID/log_dir,all"
echo "SIDdatavg,lvSIDdb2data1,/db2/SID/sapdata1,all"
echo
exit 255
}

function log {
MSGCLASS=$1
shift
case $MSGCLASS in
"info")
  echo "INFO:    $*"
;;
"warning")
  echo "WARNING: $*"
  [[ $MYRC -lt 1 ]] && MYRC=1
;;
"error")
  echo "ERROR:   $*"
  [[ $MYRC -lt 2 ]] && MYRC=2
;;
esac
}

#-------------------------------------------------------------------------
# Set the environment
#-------------------------------------------------------------------------

SCRIPTNAME=$(basename $0)
SCRIPTFULLNAME="$SCRIPTNAME $*"

#-------------------------------------------------------------------------
# Process the arguments and check for errors
#-------------------------------------------------------------------------

[[ $(whoami) != "root" ]] && log error "Script must be run as root." && exit 255
[[ "$*" == "" ]] && usage

while getopts :s:t: OPT
do
case $OPT in
s)
  [[ ${#OPTARG} -ne 3 ]] && log error "SAP system ID must be 3 characters." && exit 255
  typeset -u USID=$OPTARG
  typeset -l LSID=$OPTARG
;;
t)
  [[ ! -f $OPTARG ]] && log error "File $OPTARG does not exist." && exit 255
  MAPFILE=$OPTARG
;;
\?)
  usage
;;
:)
  usage
esac
done

[[ $USID == "" ]] && usage
[[ $MAPFILE == "" ]] && usage

#-------------------------------------------------------------------------
# Start the main script
#-------------------------------------------------------------------------

start

while IFS=, read VG LV FS SIZE; do
  VG=$(echo $VG | sed "s/SID/$USID/g" | sed "s/sid/$LSID/g")
  LV=$(echo $LV | sed "s/SID/$USID/g" | sed "s/sid/$LSID/g")
  FS=$(echo $FS | sed "s/SID/$USID/g" | sed "s/sid/$LSID/g")
  if ! vgs | grep -q $VG; then
    echo Volume group $VG does not exist.
    exit 1
  fi
  NUMPV=$(vgs | grep $VG | awk '{print $2}')
  if [[ $SIZE == "all" ]]; then
    lvcreate --stripes $NUMPV --name $LV --extents 100%FREE -y $VG
  else
    lvcreate --stripes $NUMPV --name $LV --size ${SIZE}m -y $VG
  fi
  mkfs -t xfs /dev/$VG/$LV
  mkdir -p $FS
  echo "/dev/$VG/$LV $FS  xfs  defaults  0  2" >> /etc/fstab
  mount $FS
done < $MAPFILE

finish 0
