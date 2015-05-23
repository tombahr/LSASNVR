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
RECORDTIME="20"
MAXFOLDERSIZEMB="3000"
LASTRUN1="0"
LASTRUN2="0"

STREAMOPTIONS="-w 1280 -h 720 -f 25"
while true; do
  ALARMCALL=`nc -l -p "$ALARMPORT"`
  FILEDATE=`date +%Y%m%d_%H%M%S`
  echo $FILEDATE $ALARMCALL >> $SAVEMAP$LOGFILE
  RUNNINGPROGS=`ps a | grep openRTSP`
  RUNNINGPROGS="XX $RUNNINGPROGS"
  NOW=$(date +%s)
  
  if  ! [ -z "${RUNNINGPROGS##*$CAM111URL*}" ] && ! [ $(( $NOW - $LASTRUN1)) -lt $RECORDTIME ]; then
    LASTRUN1=$NOW
    openRTSP -b 3000000 -V -v -4 $STREAMOPTIONS -d "$RECORDTIME"  "$CAM111URL$CAMURL" > "$SAVEMAP$FILEDATE$CAM111FILE" &
  fi
  
  if  ! [ -z "${RUNNINGPROGS##*$CAM222URL*}" ] && ! [ $(( $NOW - $LASTRUN2)) -lt $RECORDTIME ]; then
    LASTRUN2=$NOW
    openRTSP -b 3000000 -V -v -4 $STREAMOPTIONS -d "$RECORDTIME"  "$CAM222URL$CAMURL" > "$SAVEMAP$FILEDATE$CAM222FILE" &
  fi
  
  #delete oldest files when alocated space is used
  ls -tl $SAVEMAP*.mp4 | awk -vMFS=$MAXFOLDERSIZEMB '{x+=$5; if(x>MFS*1024*1024){ system("rm " $9) }}'
done
