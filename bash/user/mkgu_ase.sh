#!/bin/bash
#-------------------------------------------------------------------------
# Filename: mkgu_ase.sh
# Author: Donovan Hughes
# Info: Script to read SID and system number and create appropriate SAP application or HANA users and groups (not users for AnyDB)
# Set DEBUG=Y before running the script for debug mode
# Syntax:          mkgu_ase.sh -s <SID> -n <SYSNO>
# Run as:          root
#
# The general naming and numbering convention for UID and GID is:
#
# GID 2000-2099 : Cross-system SAP groups like sapsys, sapinst
# GID 2100-2199 : Cross-system Oracle groups like dba
# GID 2200-2299 : Cross-system DB2 groups (currently there are none)
# GID 2300-2399 : Cross-system MaxDB groups like sdb
# GID 2400-2499 : Cross-system HANA groups (currently there are none)
# GID 2500-2599 : Cross-system ASE groups (currently there are none)
# GID 3000-3999 : System-dependent groups (any database)
#
# UID 2000-2099 : Cross-system SAP users like sapadm
# UID 2100-2199 : Cross-system Oracle users like oracle
# UID 2200-2299 : Cross-system DB2 users like sapsr3
# UID 2300-2399 : Cross-system MaxDB users like sdb
# UID 2400-2499 : Cross-system HANA users (currently none)
# UID 2500-2599 : Cross-system ASE users (currently none)
# UID 3000-3999 : System-dependent users (any database)
#
# In the scope of this script, the following users and groups will be created:
#
# Group          GID
# -----          ---
# sapsys         2002
#
# User           UID             Groups                 Description               Home directory
# ----           ---             ------                 -----------               --------------
# syb<sid>       3<SYSNO>2       sapsys                 Sybase Administrator      /home/syb<sid>
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
log info "Please use    $SCRIPTNAME -s <SID> -n <SYSNO>"
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
GID_SAPSYS=2002
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
  typeset -l LSID=$OPTARG
;;
n)
  CHECK='^[0-9][0-9]$'
  [[ ! $OPTARG =~ $CHECK ]] && log error "SYSNO must be a 2-digit number." && exit 255
  SYSNO=$OPTARG
;;
\?)
  usage
;;
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

UID_SYBSID=3${SYSNO}2

# Create groups

if grep -q ^sapsys: /etc/group; then
  log info "Group sapsys already exists. Nothing done."
else
  groupadd -g $GID_SAPSYS sapsys && log info "Group sapsys added with GID $GID_SAPSYS." || log warning "Unknown error adding group sapsys."
fi

# Create users

if grep -q ^syb${LSID}: /etc/passwd; then
  log info "User syb${LSID} already exists."
  usermod -a -g dba -G dba,oper,sapinst syb${LSID} && log info "Group membership set for user syb${LSID}." || log warning "Unknown error setting group membership for user syb${LSID}. Continuing."
else
  useradd -c "Sybase Administrator" -d /home/syb${LSID} -g dba -G oper,sapinst -N -m -u $UID_SYBSID syb${LSID} && log info "User syb${LSID} created with UID $UID_SYBSID." || log warning "Unknown error creating user syb${LSID}. Continuing."
fi

finish