#!/bin/bash

AZCOPY=.\azcopy

SOURCEDIR="https://sapdvdnortheurope.file.core.windows.net/sapdvd"
SOURCESAS="?sv=2021-06-08&ss=f&srt=sco&sp=rwdlc&se=2024-08-12T19:22:51Z&st=2022-08-12T11:22:51Z&spr=https&sig=3xkPX6jZ614DSqzF71QgorLc3DHIriCggBWsdQuGYeo%3D"
TARGETDIR="https://sapdvdne.file.core.windows.net/sapdvd"
TARGETSAS="?sv=2021-06-08&ss=f&srt=sco&sp=rwdlc&se=2024-08-12T19:23:32Z&st=2022-08-12T11:23:32Z&spr=https&sig=PhX%2FUUJ5CYuFqLYmZMoSkqpfIKbwslrJIPKlbBRUt6g%3D"

azcopy copy ${SOURCEDIR}${SOURCESAS} ${TARGETDIR}${TARGETSAS} --recursive