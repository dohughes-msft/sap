#!/bin/bash

# Script to emulate a HANA system by listening on HANA ports

HANASYSNO=00
PORT1=3${HANASYSNO}15
PORT2=3${HANASYSNO}13

# Emulate a HANA system
nc -l -k $PORT1 &
nc -l -k $PORT2 &
