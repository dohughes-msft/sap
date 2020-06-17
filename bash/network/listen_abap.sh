#!/bin/bash

# Script to emulate an ABAP system by listening on ABAP ports
# Supply system number as argument otherwise 00 will be used

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

# Emulate an ABAP system
nc -l -k $PORT1 > /dev/null 2>&1 &
nc -l -k $PORT2 > /dev/null 2>&1 &
nc -l -k $PORT3 > /dev/null 2>&1 &
nc -l -k $PORT4 > /dev/null 2>&1 &
nc -l -k $PORT5 > /dev/null 2>&1 &
nc -l -k $PORT6 > /dev/null 2>&1 &
