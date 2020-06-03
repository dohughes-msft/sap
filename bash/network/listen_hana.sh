#!/bin/bash

# Script to emulate a HANA system by listening on HANA ports
# Supply system number as argument otherwise 00 will be used

if [[ "$*" == "" ]]; then
    HANASYSNO=00
else
    case $1 in
    [0-9][0-9])
        HANASYSNO=$1 ;;
    *)
        echo "Provide a 2-digit number as argument." && exit 2 ;;
    esac
fi

PORT1=3${HANASYSNO}15
PORT2=3${HANASYSNO}13

# Emulate a HANA system
nc -l -k $PORT1 > /dev/null 2>&1 &
nc -l -k $PORT2 > /dev/null 2>&1 &
