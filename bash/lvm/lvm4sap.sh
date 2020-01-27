#!/bin/bash
#-------------------------------------------------------------------------
# Filename: lvm4sap.sh
# Author: Donovan Hughes
# Info: Script to take a file as input and create LVM groups, volumes and filesystems
# Set DEBUG=Y before running the script for debug mode
# Syntax:          lvm4sap.sh -s <SID> -t <configfile>
# Run as:          root
#-------------------------------------------------------------------------
# The configuration file has two sections [volumegroups] and [filesystems].
# [volumegroups] contains a comma-separated list of LUNs and the volume groups they will be assigned to.
# [filesystems] contains a comma-separated list of volume groups, logical volumes, filesystems and sizes.
# Filesystem size is specified as a percentage of the total space in the volume group. The sum of sizes
# of filesystems in the same VG should therefore not exceed 100.
# "SID" is a special placeholder that will be replaced with the SID specified by parameter -s.
# You don't have to have SID in the VG or LV names but it is of course necessary for the filesystems.
# Make sure there is a blank line in between the sections.
# Maximum striping will be applied during LV creation.
#
# Sample configuration file:
# 
# [volumegroups]
# 0,SIDsapvg
# 1,SIDdatalogvg
# 2,SIDdatalogvg
# 3,SIDdatalogvg
# 4,SIDsharedvg
# 5,SIDbackupvg
#
# [filesystems]
# SIDsapvg,SIDusrsaplv,/usr/sap/SID,100
# SIDdatalogvg,SIDhanaloglv,/hana/log/SID,33
# SIDdatalogvg,SIDhanadatalv,/hana/data/SID,67
# SIDsharedvg,SIDhanasharedlv,/hana/shared/SID,100
# SIDbackupvg,SIDhanabackuplv,/hana/backup/SID,100
#
# The result of using this configuration for SID=HN2 would be:
# vgs
#   VG           #PV #LV #SN Attr   VSize   VFree
#   HN2backupvg    1   1   0 wz--n- 256.00g    0
#   HN2datalogvg   3   2   0 wz--n-   1.50t    0
#   HN2sapvg       1   1   0 wz--n-  64.00g    0
#   HN2sharedvg    1   1   0 wz--n- 512.00g    0
#
# lvs -o+lv_layout,stripes
#   LV              VG           Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert Layout     #Str
#   HN2hanabackuplv HN2backupvg  -wi-ao---- 256.00g                                                     linear        1
#   HN2hanadatalv   HN2datalogvg -wi-ao----   1.00t                                                     striped       3
#   HN2hanaloglv    HN2datalogvg -wi-ao---- 506.88g                                                     striped       3
#   HN2usrsaplv     HN2sapvg     -wi-ao----  64.00g                                                     linear        1
#   HN2hanasharedlv HN2sharedvg  -wi-ao---- 512.00g                                                     linear        1
#
# df -h
# Filesystem                               Size  Used Avail Use% Mounted on
# /dev/mapper/HN2sapvg-HN2usrsaplv          64G   33M   64G   1% /usr/sap/HN2
# /dev/mapper/HN2datalogvg-HN2hanaloglv    507G   33M  507G   1% /hana/log/HN2
# /dev/mapper/HN2datalogvg-HN2hanadatalv   1.1T   34M  1.1T   1% /hana/data/HN2
# /dev/mapper/HN2sharedvg-HN2hanasharedlv  512G   33M  512G   1% /hana/shared/HN2
# /dev/mapper/HN2backupvg-HN2hanabackuplv  256G   33M  256G   1% /hana/backup/HN2
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
log info "-t <configfile>    : Configuration file for VG/LV/FS"
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
  [[ ! -f $OPTARG ]] && log error "File $OPTARG does not exist." && exit 255
  CONFIGFILE=$OPTARG ;;
\?)
  usage ;;
:)
  usage
esac
done

[[ $SID == "" ]] && usage
[[ $CONFIGFILE == "" ]] && usage

#-------------------------------------------------------------------------
# Start the main script
#-------------------------------------------------------------------------

start

#-------------------------------------------------------------------------
# Parse the configuration file and check that all is in order
#-------------------------------------------------------------------------

VGS=$(grep -v ^# $CONFIGFILE | awk -v RS='' '/volumegroups/' | tail -n +2 | sed "s/SID/$SID/g" | sed "s/sid/$LSID/g")
NUMDISKFILE=$(echo -n "$VGS" | grep -c '^')
NUMDISKVM=$(ls -1 /dev/disk/azure/scsi1/lun* | wc -l)
FILESYS=$(grep -v ^# $CONFIGFILE | awk -v RS='' '/filesystems/' | tail -n +2 | sed "s/SID/$SID/g" | sed "s/sid/$LSID/g")
VGLIST1=$(echo "$VGS" | cut -d \, -f 2 | uniq)
VGLIST2=$(echo "$FILESYS" | cut -d \, -f 1 | uniq)

# Check if the [volumegroups] and [filesystems] sections are consistent with each other
if [[ $VGLIST1 != $VGLIST2 ]]; then
  for VG in $VGLIST2; do
    if ! grep -q $VG <<<$VGLIST1; then
      log error "Volume group $VG used in [filesystems] does not appear in [volumegroups]. Please check the configuration file."
      finish
    fi
  done
  for VG in $VGLIST1; do
    if ! grep -q $VG <<<$VGLIST2; then
      log warning "Volume group $VG in [volumegroups] does not appear in [filesystems]."
    fi
  done
fi

# Check if the number of disks in the [volumegroups] section matches the disks on the VM
if [ $NUMDISKFILE -gt $NUMDISKVM ]; then
  log error "The number of disks attached to the VM ($NUMDISKVM) is less than the number of disks in the [volumegroups] section of the configuration file ($NUMDISKFILE)."
  finish
elif [ $NUMDISKFILE -lt $NUMDISKVM ]; then
  log warning "The number of disks attached to the VM ($NUMDISKVM) is larger than the number of disks in the [volumegroups] section of the configuration file ($NUMDISKFILE)."
fi

# Create the volume groups
log info "Creating volume groups..."
echo

LUNCOUNT=1

echo "$VGS" | while IFS=, read LUN VG; do
  TOTALLUNS=$(grep ,$VG <<<"$VGS" | wc -l)
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
done

# Create the logical volumes and filesystems
echo
log info "Creating logical volumes and filesystems..."
echo

# Backup fstab first
cp -p /etc/fstab /etc/fstab.$(date +%Y%m%d%H%M)

echo "$FILESYS" | while IFS=, read VG LV FS SIZE; do
  NUMPV=$(vgs | grep $VG | awk '{print $2}')
  log info "Creating logical volume $LV..."
  echo
  lvcreate --stripes $NUMPV --name $LV --extents ${SIZE}%VG -y $VG
  echo
  log info "Creating $FSTYPE filesystem $FS..."
  echo
  mkfs -t $FSTYPE /dev/$VG/$LV
  echo
  mkdir -p $FS
  echo "/dev/$VG/$LV $FS  $FSTYPE  defaults  0 0" >> /etc/fstab
  log info "Mounting filesystem $FS..."
  mount $FS
done

finish