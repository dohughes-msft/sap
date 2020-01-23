#!/bin/bash
#-------------------------------------------------------------------------
# Filename: mkvg.sh
# Author: Donovan Hughes
# Info: Script to take a file as input and create VGs from the LUNs
# Set DEBUG=Y before running the script for debug mode
# Syntax:          mkvg.sh -s <SID> -t <tablefile>
# Run as:          root
#
# Sample input table:
#
# LUN,VG
# SID in the table will be replaced by the provided SID when VGs are created.
#
# 0,SIDsapvg
# 1,SIDlogvg
# 2,SIDdatavg
# 3,SIDdatavg
# 4,SIDdatavg
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
log info "-t <tablefile>     : LUN-to-VG mapping file"
log info "A mapping file should look like:"
echo
echo "0,SIDsapvg"
echo "1,SIDlogvg"
echo "2,SIDdatavg"
echo "3,SIDdatavg"
echo "4,SIDdatavg"
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

LUNCOUNT=1

while IFS=, read LUN VG; do
  TOTALLUNS=$(grep ,$VG$ $MAPFILE | wc -l)
  VG=$(echo $VG | sed "s/SID/$USID/g" | sed "s/sid/$LSID/g")
  if [ $TOTALLUNS -gt 1 ] ; then
    ## There are multiple LUNs in the VG so wait until the last line before creating
	if [ $LUNCOUNT -eq 1 ]; then
	  STMT="vgcreate $VG /dev/disk/azure/scsi1/lun${LUN}"
	  LUNCOUNT=$(( $LUNCOUNT + 1 ))
	elif [ $LUNCOUNT -lt $TOTALLUNS ]; then
	  STMT="$STMT /dev/disk/azure/scsi1/lun${LUN}"
	  LUNCOUNT=$(( $LUNCOUNT + 1 ))
	else
	  STMT="$STMT /dev/disk/azure/scsi1/lun${LUN}"
          $STMT
	  LUNCOUNT=1
	fi
  else
    vgcreate $VG /dev/disk/azure/scsi1/lun${LUN}
  fi
done < $MAPFILE

finish 0
