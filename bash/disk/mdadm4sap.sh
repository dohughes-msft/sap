#!/bin/bash
#-------------------------------------------------------------------------
# Filename: mdadm4sap.sh
# Author: Donovan Hughes
# Info: Script to take a file as input and create mdadm arrays and filesystems
# Set DEBUG=Y before running the script for debug mode
# Syntax:          mdadm4sap.sh -s <SID> -t <configfile>
# Run as:          root
#-------------------------------------------------------------------------
# The configuration file can be either a local file on the VM or a network file accessed via http/https.
#
# The configuration file has two sections [arrays] and [filesystems].
# [arrays] contains a comma-separated list of LUNs and array names.
# [filesystems] contains a comma-separated list of array names and filesystems.
# There can be only one filesystem per array and it will be created using 100% of the space.
# "SID" is a special placeholder that will be replaced with the SID specified by parameter -s.
# Make sure there is a blank line in between the sections.
# The arrays are created as RAID-0 with striping.
#
# Sample configuration file:
# 
# [arrays]
# 0,sapexe
# 1,hanadata
# 2,hanadata
# 3,hanalog
# 4,hanashared
# 5,hanabackup
#
# [filesystems]
# sapexe,/usr/sap/SID
# hanadata,/hana/data/SID
# hanalog,/hana/log/SID
# hanashared,/hana/shared/SID
# hanabackup,/hana/backup/SID
#
# The result of using this configuration for SID=HN2 would be:
#
# lsblk
# NAME      MAJ:MIN RM    SIZE RO TYPE  MOUNTPOINT
# sdc         8:32   0     64G  0 disk
# └─sdc1      8:33   0     64G  0 part
#   └─md127   9:127  0     64G  0 raid0 /usr/sap/HN2
# sdd         8:48   0    256G  0 disk
# └─sdd1      8:49   0    256G  0 part
#   └─md123   9:123  0  255.9G  0 raid0 /hana/backup/HN2
# sde         8:64   0    512G  0 disk
# └─sde1      8:65   0    512G  0 part
#   └─md124   9:124  0  511.9G  0 raid0 /hana/shared/HN2
# # sdf         8:80   0    512G  0 disk
# └─sdf1      8:81   0    512G  0 part
#   └─md126   9:126  0 1023.8G  0 raid0 /hana/data/HN2
# sdg         8:96   0    512G  0 disk
# └─sdg1      8:97   0    512G  0 part
#   └─md126   9:126  0 1023.8G  0 raid0 /hana/data/HN2
# sdh         8:112  0    512G  0 disk
# └─sdh1      8:113  0    512G  0 part
#   └─md125   9:125  0  511.9G  0 raid0 /hana/log/HN2
#
# df -h
# Filesystem      Size  Used Avail Use% Mounted on
# /dev/md127       64G   33M   64G   1% /usr/sap/HN2
# /dev/md126      1.0T   34M  1.0T   1% /hana/data/HN2
# /dev/md125      512G   33M  512G   1% /hana/log/HN2
# /dev/md124      512G   33M  512G   1% /hana/shared/HN2
# /dev/md123      256G   33M  256G   1% /hana/backup/HN2
#
#-------------------------------------------------------------------------
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
MYRC=0
}

function finish {
case $MYRC in
0)
  LEVEL="success" ;;
1)
  LEVEL="warning" ;;
*)
  LEVEL="error" ;;
esac
log info "Stop execution of $SCRIPTFULLNAME with return code $MYRC ($LEVEL)."
log info $(date)
echo
exit $MYRC
}

function usage {
log info "Please use    $SCRIPTNAME -s <SID> -t <configfile>"
log info
log info "-s <SID>           : SAP system ID"
log info "-t <configfile>    : Configuration file for arrays and filesystems"
log info
log info "Examine the contents of this script for a description of configuration file syntax."
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
FSTYPE="xfs"

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
  typeset -l LSID=$OPTARG
  typeset -u SID=$OPTARG ;;
t)
  CONFIGFILE=$OPTARG ;;
\?)
  usage ;;
:)
  usage
esac
done

[[ $SID == "" ]] && usage
[[ $CONFIGFILE == "" ]] && usage

if [[ $CONFIGFILE = https://* || $CONFIGFILE = http://* ]]; then
  # File is a network file so download a temporary copy
  TMPFILE=/tmp/mdadm4sap.tmp.$$
  curl -f -s $CONFIGFILE > $TMPFILE
  if [[ $? -ne 0 ]]; then
    log error "Error accessing configuration file URI. Please check that this file is reachable from the VM."
    rm $TMPFILE
    exit 255
  fi
  CONFIGFILE=$TMPFILE
else
  [[ ! -f $CONFIGFILE ]] && log error "File $CONFIGFILE does not exist." && exit 255
fi

#-------------------------------------------------------------------------
# Start the main script
#-------------------------------------------------------------------------

start

#-------------------------------------------------------------------------
# Parse the configuration file and check that all is in order
#-------------------------------------------------------------------------

if ! grep -q '^\[arrays\]' $CONFIGFILE; then
  log error "Section [arrays] not found in configuration file."
  finish
elif ! grep -q '^\[filesystems\]' $CONFIGFILE; then
  log error "Section [filesystems] not found in configuration file."
  finish
fi

ARRAYS=$(grep -v ^# $CONFIGFILE | awk -v RS='' '/arrays/' | tail -n +2 | sed "s/SID/$SID/g" | sed "s/sid/$LSID/g")
NUMDISKFILE=$(echo -n "$ARRAYS" | grep -c '^')
NUMDISKVM=$(ls -1 /dev/disk/azure/scsi1/lun* 2>/dev/null | wc -l)

# Add a check that the LUN numbers are correct!

FILESYS=$(grep -v ^# $CONFIGFILE | awk -v RS='' '/filesystems/' | tail -n +2 | sed "s/SID/$SID/g" | sed "s/sid/$LSID/g")
ARRAYLIST1=$(echo "$ARRAYS" | cut -d \, -f 2 | uniq)
ARRAYLIST2=$(echo "$FILESYS" | cut -d \, -f 1 | uniq)

# Check if the [arrays] and [filesystems] sections are consistent with each other
if [[ $ARRAYLIST1 != $ARRAYLIST2 ]]; then
  for ARRAY in $ARRAYLIST2; do
    if ! grep -q $ARRAY <<<$ARRAYLIST1; then
      log error "Array $ARRAY used in [filesystems] does not appear in [arrays]. Please check the configuration file."
      finish
    fi
  done
  for ARRAY in $ARRAYLIST1; do
    if ! grep -q $ARRAY <<<$ARRAYLIST2; then
      log warning "Array $ARRAY in [arrays] does not appear in [filesystems]. The array will be created but not used."
    fi
  done
fi

# Check if the number of disks in the [arrays] section matches the disks on the VM
if [ $NUMDISKFILE -gt $NUMDISKVM ]; then
  log error "The number of disks attached to the VM ($NUMDISKVM) is less than the number of disks in the [arrays] section of the configuration file ($NUMDISKFILE)."
  finish
elif [ $NUMDISKFILE -lt $NUMDISKVM ]; then
  log warning "The number of disks attached to the VM ($NUMDISKVM) is larger than the number of disks in the [arrays] section of the configuration file ($NUMDISKFILE)."
  log warning "Some disks will remain unallocated."
fi

#-------------------------------------------------------------------------
# Start the actual configuration
#-------------------------------------------------------------------------

# Create disk partitions
log info "Creating disk partitions..."
echo

echo "$ARRAYS" | while IFS=, read LUN DUMMY; do
  sh -c "echo -e \"n\n\n\n\n\nt\nfd\nw\n\" | fdisk /dev/disk/azure/scsi1/lun${LUN}"
done

# Wait a few seconds for the partitions to be written
sleep 5

# Create the arrays
log info "Creating arrays..."
echo

LUNCOUNT=1

# Loop for creation of the arrays
echo "$ARRAYS" | while IFS=, read LUN ARRAY; do
  TOTALLUNS=$(grep ,$ARRAY <<<"$ARRAYS" | wc -l)
  if [ $TOTALLUNS -gt 1 ] ; then
    ## There are multiple LUNs in the array so wait until the last line before creating
    if [ $LUNCOUNT -eq 1 ]; then
      STMT="mdadm --create --verbose /dev/md/$ARRAY --level=0 --raid-devices=$TOTALLUNS /dev/disk/azure/scsi1/lun${LUN}-part1"
      LUNCOUNT=$(( $LUNCOUNT + 1 ))
    elif [ $LUNCOUNT -lt $TOTALLUNS ]; then
      STMT="$STMT /dev/disk/azure/scsi1/lun${LUN}-part1"
      LUNCOUNT=$(( $LUNCOUNT + 1 ))
    else
      STMT="$STMT /dev/disk/azure/scsi1/lun${LUN}-part1"
      $STMT
      LUNCOUNT=1
    fi
  else
    mdadm --create --verbose /dev/md/$ARRAY --level=0 --raid-devices=1 --force /dev/disk/azure/scsi1/lun${LUN}-part1
  fi
done

# Create the filesystems
echo
log info "Creating filesystems..."
echo

# Backup fstab first
cp -p /etc/fstab /etc/fstab.$(date +%Y%m%d%H%M)

# Loop for creation of filesystems
echo "$FILESYS" | while IFS=, read ARRAY FS; do
  log info "Creating $FSTYPE filesystem $FS..."
  echo
  mkfs -t $FSTYPE /dev/md/$ARRAY
  echo
  mkdir -p $FS
  echo "/dev/md/$ARRAY $FS  $FSTYPE  defaults,nofail  0 0" >> /etc/fstab
  log info "Mounting filesystem $FS..."
  mount $FS
done

# Save the mdadm configuration
mkdir -p /etc/mdadm
mdadm --detail --scan > /etc/mdadm/mdadm.conf

[[ -n "$TMPFILE" ]] && rm $TMPFILE

finish