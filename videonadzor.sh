#!/bin/sh
ALARMPORT="15002"
SAVEMAP="/home/tomislav/videonadzor/"
LOGFILE="alarmlog.txt"
CAMURL="user=admin_password=_channel=1_stream=0.sdp"
#rtsp://192.168.5.15/user=admin_password=_channel=1_stream=0.sdp
CAM111URL="rtsp://192.168.5.15:554/"
CAM222URL="rtsp://192.168.5.222:554/"
CAM111HEX="0x0F05A8C0"
CAM222HEX="0xDE00A8C0"
CAM111FILE="cam111.mp4"
CAM222FILE="cam222.mp4"
RECORDTIME="22"
MAXFOLDERSIZEMB="2000"
STREAMOPTIONS="-w 1280 -h 720 -f 25"
RECORDING="recording"

record(){
        touch $RECORDING
        FILEDATE=`date +%Y%m%d_%H%M%S`
        echo $FILEDATE
        openRTSP -b 3000000 -V -v -4 $STREAMOPTIONS  "$CAM111URL$CAMURL" > "$SAVEMAP$FILEDATE$CAM111FILE" &
        PID=$!
        while [ $(($(date +%s) - $(date +%s -r $RECORDING) )) -lt $RECORDTIME  ] ; do
                sleep 5
        done
	kill -USR1 $PID
	rm $RECORDING

        ls -tl $SAVEMAP*.mp4 | awk -vMFS=$MAXFOLDERSIZEMB '{x+=$5; if(x>MFS*1024*1024){ system("rm " $9) }}'
}

rm $RECORDING
while true; do
	ALARMCALL=`nc -l -p "$ALARMPORT"`
	echo $FILEDATE $ALARMCALL >> $SAVEMAP$LOGFILE
	if   [ -z "${ALARMCALL##*$CAM111HEX*}" ] ; then
		if ! [ -e $RECORDING ] ; then
			record &
		else
			touch $RECORDING
		fi
	fi
done
