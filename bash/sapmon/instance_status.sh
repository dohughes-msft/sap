#!/bin/bash

SYSNO="00"
CMDOUTPUT=$(sapcontrol -nr $SYSNO -function GetSystemInstanceList | grep ^$(hostname) | sed 's/ //g')

while IFS= read -r LINE
do
    while IFS=, read HOST INSTANCE DUMMY1 DUMMY2 DUMMY3 SERVICES STATUS
    do
        [[ $INSTANCE -lt 10 ]] && INSTANCE="0$INSTANCE"
        echo "{\"host\":\"$HOST\",\"instance\":\"$INSTANCE\",\"services\":\"$SERVICES\",\"status\":\"$STATUS\"}" | logger -p local1.info -t SAPInstanceStatus
    done < <(printf '%s\n' "$LINE")
done < <(printf '%s\n' "$CMDOUTPUT")
