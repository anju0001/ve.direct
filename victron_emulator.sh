#!/bin/bash

DEVICE="$1"
if [[ $DEVICE ]]
then
	stty -F $DEVICE 19200 cs8 -cstopb -parenb raw
fi

#decimal to ascii function
dec2ascii() {
  printf \\$(printf '%03o' $1)
}

#checksum calculate function
get_checksum() {
	INPUT="$1"
	LENGTH=${#INPUT}
        #length includes 0!
        LENGTH=$(($LENGTH - 1))
        CHECKSUM=0
        BS=0
        for pos in $(seq 0 $LENGTH)
        do
                #check for escaped character
                if [[ $BS -eq 0 ]]
                then
                        CHAR=${INPUT:$pos:1}
                else
                        CHAR=$CHAR${INPUT:$pos:1}
                        BS=0
                fi
                if [[ $CHAR = "\\" ]]
                then
                        BS=1;
                        continue;
                fi

                ASCII=$(ascii -t "$CHAR"|head -n1|cut -d' ' -f4)
                CHECKSUM=$(($CHECKSUM + $ASCII))
        done
	echo $CHECKSUM
}

#PARAMETER SET FOR BlueSolar 75/15
PID="0xA042"
FW="156"
SER="AA11111AAAA"
V=""
I=""
VPV=""
PPV=""
CS=""
MPPT=""
ERR="0"
LOAD=""
IL="0"
H19="0"
H20="0"
H21="0"
H22="0"
H23="0"
HSDS="0"
Checksum="0"

while true
do
	V=$(shuf -i 11500-14500 -n1)
	I=$(shuf -i 100-8000 -n1)
	VPV=$(shuf -i 55500-70500 -n1)
	PPV=$(shuf -i 5-300 -n1)
	CS=$(shuf -e 0 2 3 4 5 7 247 252 -n1)
	MPPT=$(shuf -i 0-2 -n1)
	LOAD=$(shuf -e OFF ON -n1)
	HSDS=$(date +%j)
	STRING="\r\nPID\t$PID\r\nFW\t$FW\r\nSER#\t$SER\r\nV\t$V\r\nI\t$I\r\nVPV\t$VPV\r\nPPV\t$PPV\r\nCS\t$CS\r\nMPPT\t$MPPT\r\nERR\t$ERR\r\nLOAD\t$LOAD\r\nIL\t$IL\r\nH19\t$H19\r\nH20\t$H20\r\nH21\t$H21\r\nH22\t$H22\r\nH23\t$H23\r\nHSDS\t$HSDS\r\nChecksum\t"

	CHECKSUM=$(get_checksum "$STRING")
	CHECKSUM=$(($CHECKSUM % 256))
	CHECKSUM=$((256 - $CHECKSUM))	
	MISSING=$(dec2ascii $CHECKSUM)
	STRING=$STRING$MISSING
	CHECKSUM=$(get_checksum "$STRING")
	CHECKSUM=$(($CHECKSUM % 256))
	if [[ $CHECKSUM -eq 0 ]]
	then
		if [[ $DEVICE ]]
		then
			echo -ne "$STRING" >$DEVICE
		else
			echo -ne "$STRING"
		fi
	else
		echo -ne "\nERROR IN CHECKSUM, SKIP FRAME\n"
	fi
	sleep 1
done
