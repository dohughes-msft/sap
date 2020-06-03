#!/bin/bash

# Script to emulate a HANA client by connecting to HANA ports
# Supply system number as argument otherwise 00 will be used

# DB host
DBHOST=dbvm
# Connection interval
INTERVALSEC=5

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

# Emulate a HANA client
while true; do
    echo "" | telnet $DBHOST $PORT1
    echo "" | telnet $DBHOST $PORT2
    sleep $INTERVALSEC
done
