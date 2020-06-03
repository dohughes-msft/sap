#!/bin/bash

# Script to emulate an ABAP client by connecting to ABAP ports
# Supply system number as argument otherwise 00 will be used

# DB host
APPHOST=appvm
# Connection interval
INTERVALSEC=5

if [[ "$*" == "" ]]; then
    ABAPSYSNO=00
else
    case $1 in
    [0-9][0-9])
        ABAPSYSNO=$1 ;;
    *)
        echo "Provide a 2-digit number as argument." && exit 2 ;;
    esac
fi

PORT1=32${ABAPSYSNO}
PORT2=33${ABAPSYSNO}
PORT3=36${ABAPSYSNO}
PORT4=39${ABAPSYSNO}
PORT5=80${ABAPSYSNO}
PORT6=81${ABAPSYSNO}

# Emulate an ABAP client
while true; do
    echo "" | telnet $APPHOST $PORT1
    echo "" | telnet $APPHOST $PORT2
    echo "" | telnet $APPHOST $PORT3
    echo "" | telnet $APPHOST $PORT4
    echo "" | telnet $APPHOST $PORT5
    echo "" | telnet $APPHOST $PORT6
    sleep $INTERVALSEC
done
