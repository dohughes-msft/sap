#!/bin/bash
#-------------------------------------------------------------------------
# Filename: mkgu_db6.sh
# Author: Donovan Hughes
# Info: Script to read SID and system number and create appropriate DB2 users and groups (not SAP users)
# Set DEBUG=Y before running the script for debug mode
# Syntax:          mkgu_db6.sh -s <SID> -n <SYSNO>
# Run as:          root
#
# The general naming and numbering convention for UID and GID is:
#
# GID 2000-2099 : Cross-system SAP groups like sapsys, sapinst
# GID 2100-2199 : Cross-system Oracle groups like dba
# GID 2200-2299 : Cross-system DB2 groups (currently there are none)
# GID 2300-2399 : Cross-system MaxDB groups like sdb
# GID 2400-2499 : Cross-system HANA groups (currenty there are none)
# GID 3000-3999 : System-dependent groups (any database)
#
# UID 2000-2099 : Cross-system SAP users like sapadm
# UID 2100-2199 : Cross-system Oracle users like oracle
# UID 2200-2299 : Cross-system DB2 users like sapsr3
# UID 2300-2399 : Cross-system MaxDB users like sdb
# UID 2400-2499 : Cross-system HANA users (currently none)
# UID 3000-3999 : System-dependent users (any database)
#
# In the scope of this script, the following users and groups will be created:
#
# Group          GID
# -----          ---
# sapinst        2001
# db<sid>ctl     3{SYSNO}1
# db<sid>adm     3{SYSNO}2
# db<sid>mnt     3{SYSNO}3
# db<sid>mon     3{SYSNO}4
#
# User           UID             Groups                 Description                   Home directory
# ----           ---             ------                 -----------                   --------------
# sapsr3         2201            db<sid>mon             DB2 Schema Owner for ABAP     /home/sapsr3
# sapsr3db       2202            db<sid>mon             DB2 Schema Owner for Java     /home/sapsr3db
# db2<sid>       3<SYSNO>2       db<sid>adm,sapinst     DB2 Administrator             /home/db2<sid>
#
# Additional group assignments:
#
# User           Group
# ----           -----
# <sid>adm       db<sid>ctl
#
# Change the defaults using the constants below in the environment section.

[[ $DEBUG == 'Y' ]] && set -x

#-------------------------------------------------------------------------
# Functions
#-------------------------------------------------------------------------

function start {
log info Start execution of $SCRIPTFULLNAME
log info $(date)
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
log info "Please use    $SCRIPTNAME -s <SID> -n <SYSNO> [-o]"
log info
log info "-s <SID>           : SAP system ID"
log info "-n <SYSNO>         : SAP system number of the PAS"
log info
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
MYRC=0
GID_SAPINST=2001
UID_SAPSR3=2002
UID_SAPSR3DB=2003
# Others are set below once we know SYSNO

#-------------------------------------------------------------------------
# Process the arguments and check for errors
#-------------------------------------------------------------------------

[[ $(whoami) != "root" ]] && log error "Script must be run as root." && exit 255
[[ "$*" == "" ]] && usage

while getopts :s:n: OPT
do
case $OPT in
s)
  CHECK='^[A-Z][A-Z0-9][A-Z0-9]$'
  [[ ! $OPTARG =~ $CHECK ]] && log error "SID must be 3 characters starting with a letter." && exit 255
  typeset -u USID=$OPTARG
  typeset -l LSID=$OPTARG ;;
n)
  CHECK='^[0-9][0-9]$'
  [[ ! $OPTARG =~ $CHECK ]] && log error "SYSNO must be a 2-digit number." && exit 255
  SYSNO=$OPTARG ;;
\?)
  usage ;;
:)
  usage
esac
done

[[ $USID == "" ]] && usage
[[ $SYSNO == "" ]] && usage

#-------------------------------------------------------------------------
# Start the main script
#-------------------------------------------------------------------------

start

GID_DBSIDCTL=3${SYSNO}1
GID_DBSIDADM=3${SYSNO}2
GID_DBSIDMNT=3${SYSNO}3
GID_DBSIDMON=3${SYSNO}4
UID_DB2SID=3${SYSNO}2

# Create groups

if grep -q ^sapinst: /etc/group; then
  log info "Group sapinst already exists. Nothing done."
else
  groupadd -g $GID_SAPINST sapinst && log info "Group sapinst created with GID $GID_SAPINST." || log warning "Unknown error creating group sapinst. Continuing."
fi
if grep -q ^db${LSID}ctl: /etc/group; then
  log info "Group db${LSID}ctl already exists. Nothing done."
else
  groupadd -g $GID_DBSIDCTL db${LSID}ctl && log info "Group db${LSID}ctl added with GID $GID_DBSIDCTL." || log info "Unknown error adding group db${LSID}ctl."
fi
if grep -q ^db${LSID}adm: /etc/group; then
  log info "Group db${LSID}adm already exists. Nothing done."
else
  groupadd -g $GID_DBSIDADM db${LSID}adm && log info "Group db${LSID}adm added with GID $GID_DBSIDADM." || log info "Unknown error adding group db${LSID}adm."
fi
if grep -q ^db${LSID}mnt: /etc/group; then
  log info "Group db${LSID}mnt already exists. Nothing done."
else
  groupadd -g $GID_DBSIDMNT db${LSID}mnt && log info "Group db${LSID}mnt added with GID $GID_DBSIDMNT." || log info "Unknown error adding group db${LSID}mnt."
fi
if grep -q ^db${LSID}mon: /etc/group; then
  log info "Group db${LSID}mon already exists. Nothing done."
else
  groupadd -g $GID_DBSIDMON db${LSID}mon && log info "Group db${LSID}mon added with GID $GID_DBSIDMON." || log info "Unknown error adding group db${LSID}mon."
fi

# Create users

if grep -q ^sapsr3: /etc/passwd; then
  log info "User sapsr3 already exists."
  usermod -a -g db${LSID}mon -G db${LSID}mon sapsr3
else
  useradd -c "DB2 Schema Owner for ABAP" -d /home/sapsr3 -g db${LSID}mon -N -m -u $UID_SAPSR3 sapsr3 && log info "User sapsr3 added with UID $UID_SAPSR3." || log info "Unknown error adding user sapsr3."
fi
if grep -q ^sapsr3db: /etc/passwd; then
  log info "User sapsr3db already exists."
  usermod -a -g db${LSID}mon -G db${LSID}mon sapsr3db
else
  useradd -c "DB2 Schema Owner for ABAP" -d /home/sapsr3db -g db${LSID}mon -N -m -u $UID_SAPSR3DB sapsr3db && log info "User sapsr3db added with UID $UID_SAPSR3DB." || log info "Unknown error adding user sapsr3db."
fi
if grep -q ^db2${LSID}: /etc/passwd; then
  log info "User db2${LSID} already exists."
  usermod -a -g db${LSID}adm -G db${LSID}adm db2${LSID}
else
  useradd -c "DB2 Administrator" -d /home/db2${LSID} -g db${LSID}adm -G sapinst -N -m -u $UID_DB2SID db2${LSID} && log info "User db2${LSID} added with UID $UID_DB2SID." || log info "Unknown error adding user db2${LSID}."
fi

# Final group assignments

if grep -q ^${LSID}adm: /etc/passwd; then
  usermod -a -G db${LSID}ctl ${LSID}adm && log info "User ${LSID}adm added to group db${LSID}ctl." || log info "Unknown error adding user ${LSID}adm to group db${LSID}ctl."
else
  log warning "${LSID}adm does not exist so was not added to the database groups. You can re-run this script after creating this user."
fi

finish