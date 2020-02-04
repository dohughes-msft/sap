#!/bin/bash
#-------------------------------------------------------------------------
# Filename: mkgu_ora.sh
# Author: Donovan Hughes
# Info: Script to read SID and system number and create appropriate Oracle users and groups
# Set DEBUG=Y before running the script for debug mode
# Syntax:          mkgu_ora.sh -s <SID> -n <SYSNO> [-o]
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
# dba            2101
# oper           2102
# asmdba         2103     (Oracle 11 with ASM or Oracle 12)
# asmoper        2104     (Oracle 11 with ASM or Oracle 12)
# asmadmin       2105     (Oracle 11 with ASM or Oracle 12)
# oinstall       2106     (Oracle 11 with ASM or Oracle 12)
#
# User           UID             Groups                                                 Description                   Home directory
# ----           ---             ------                                                 -----------                   --------------
# oracle         2101            dba,oper,sapinst,asmoper,asmadmin,asmdba,oinstall      Oracle Software Owner         /home/oracle
# ora<sid>       3<SYSNO>2       dba,oper,sapinst,oinstall                              Oracle Administrator          /home/ora<sid>
#
# Additional group assignments:
#
# User           Group
# ----           -----
# <sid>adm       oper
# <sid>adm       dba
#
# Change the defaults using the constants below.

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
log info "-o                 : (Optional) Add this flag if you are using Oracle 11 with ASM, or Oracle 12 or higher"
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
ORA12=N
GID_SAPINST=2001
GID_DBA=2101
GID_OPER=2102
GID_ASMDBA=2103
GID_ASMOPER=2104
GID_ASMADMIN=2105
GID_OINSTALL=2106
UID_ORACLE=2101
# Others are set below once we know SYSNO

#-------------------------------------------------------------------------
# Process the arguments and check for errors
#-------------------------------------------------------------------------

[[ $(whoami) != "root" ]] && log error "Script must be run as root." && exit 255
[[ "$*" == "" ]] && usage

while getopts :s:n:o OPT
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
o)
  ORA12=Y ;;  
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

UID_ORASID=3${SYSNO}2

# Create groups

if grep -q ^sapinst: /etc/group; then
  log info "Group sapinst already exists. Nothing done."
else
  groupadd -g $GID_SAPINST sapinst && log info "Group sapinst created with GID $GID_SAPINST." || log warning "Unknown error creating group sapinst. Continuing."
fi
if grep -q ^dba: /etc/group; then
  log info "Group dba already exists. Nothing done."
else
  groupadd -g $GID_DBA dba && log info "Group dba created with GID $GID_DBA." || log warning "Unknown error creating group dba. Continuing."
fi
if grep -q ^oper: /etc/group; then
  log info "Group oper already exists. Nothing done."
else
  groupadd -g $GID_OPER oper && log info "Group oper created with GID $GID_OPER." || log warning "Unknown error creating group oper. Continuing."
fi
if [[ $ORA12 == "Y" ]]; then
  if grep -q ^asmdba: /etc/group; then
    log info "Group asmdba already exists. Nothing done."
  else
    groupadd -g $GID_ASMDBA asmdba && log info "Group asmdba created with GID $GID_ASMDBA." || log warning "Unknown error creating group asmdba. Continuing."
  fi
  if grep -q ^asmoper: /etc/group; then
    log info "Group asmoper already exists. Nothing done."
  else
    groupadd -g $GID_ASMOPER asmoper && log info "Group asmoper created with GID $GID_ASMOPER." || log warning "Unknown error creating group asmoper. Continuing."
  fi
  if grep -q ^asmadmin: /etc/group; then
    log info "Group asmadmin already exists. Nothing done."
  else
    groupadd -g $GID_ASMADMIN asmadmin && log info "Group asmadmin created with GID $GID_ASMADMIN." || log warning "Unknown error creating group asmadmin. Continuing."
  fi
  if grep -q ^oinstall: /etc/group; then
    log info "Group oinstall already exists. Nothing done."
  else
    groupadd -g $GID_OINSTALL oinstall && log info "Group oinstall created with GID $GID_OINSTALL." || log warning "Unknown error creating group oinstall. Continuing."
  fi
fi

# Create users

if [[ $ORA12 == "Y" ]]; then
  if grep -q ^oracle: /etc/passwd; then
    log info "User oracle already exists."
    usermod -a -g dba -G dba,oper,sapinst,asmoper,asmadmin,asmdba,oinstall oracle && log info "Group membership set for user oracle." || log warning "Unknown error setting group membership for user oracle. Continuing."
  else
    useradd -c "Oracle Software Owner" -d /home/oracle -g dba -G oper,sapinst,asmoper,asmadmin,asmdba,oinstall -N -m -u $UID_ORACLE oracle && log info "User oracle created with UID $UID_ORACLE." || log warning "Unknown error creating user oracle. Continuing."
  fi
  if grep -q ^ora${LSID}: /etc/passwd; then
    log info "User ora${LSID} already exists."
    usermod -a -g dba -G dba,oper,sapinst,oinstall ora${LSID} && log info "Group membership set for user ora${LSID}." || log warning "Unknown error setting group membership for user ora${LSID}. Continuing."
  else
    useradd -c "Oracle Administrator" -d /home/ora${LSID} -g dba -G oper,sapinst,oinstall -N -m -u $UID_ORASID ora${LSID} && log info "User ora${LSID} created with UID $UID_ORASID." || log warning "Unknown error creating user ora${LSID}. Continuing."
  fi
else
  if grep -q ^ora${LSID}: /etc/passwd; then
    log info "User ora${LSID} already exists."
    usermod -a -g dba -G dba,oper,sapinst ora${LSID} && log info "Group membership set for user ora${LSID}." || log warning "Unknown error setting group membership for user ora${LSID}. Continuing."
  else
    useradd -c "Oracle Administrator" -d /home/ora${LSID} -g dba -G oper,sapinst -N -m -u $UID_ORASID ora${LSID} && log info "User ora${LSID} created with UID $UID_ORASID." || log warning "Unknown error creating user ora${LSID}. Continuing."
  fi
fi

# Final group assignments

if grep -q ^${LSID}adm: /etc/passwd; then
  usermod -a -G dba ${LSID}adm && log info "User ${LSID}adm added to group dba." || log warning "Unknown error adding user ${LSID}adm to group dba. Continuing."
  usermod -a -G oper ${LSID}adm && log info "User ${LSID}adm added to group oper." || log warning "Unknown error adding user ${LSID}adm to group oper. Continuing."
  if [[ $ORA12 == "Y" ]]; then
    usermod -a -G asmdba ${LSID}adm && log info "User ${LSID}adm added to group asmdba." || log warning "Unknown error adding user ${LSID}adm to group asmdba. Continuing."
    usermod -a -G asmoper ${LSID}adm && log info "User ${LSID}adm added to group asmoper." || log warning "Unknown error adding user ${LSID}adm to group asmoper. Continuing."
  fi
else
  log warning "${LSID}adm does not exist so was not added to the database groups. You can re-run this script after creating this user."
fi

finish