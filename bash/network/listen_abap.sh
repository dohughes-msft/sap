#!/bin/bash

# Script to emulate an ABAP system by listening on ABAP ports

ABAPSYSNO=00
PORT1=32${ABAPSYSNO}
PORT2=33${ABAPSYSNO}
PORT3=36${ABAPSYSNO}
PORT4=39${ABAPSYSNO}
PORT5=80${ABAPSYSNO}
PORT6=81${ABAPSYSNO}

# Emulate a HANA system
nc -l -k $PORT1 &
nc -l -k $PORT2 &
nc -l -k $PORT3 &
nc -l -k $PORT4 &
nc -l -k $PORT5 &
nc -l -k $PORT6 &
