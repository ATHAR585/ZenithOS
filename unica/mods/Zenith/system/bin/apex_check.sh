#!/system/bin/sh
# APEX Selective Wipe Script
# Created by @szucsy92 & @A1X31

FILE="/data/local/tmp/boot_attempts"
LOG_FILE="/data/local/tmp/zenith_guardian.log"

[ ! -f "$FILE" ] && exit 0
VAL=$(cat "$FILE")

# Trigger selective wipe only after the 2nd consecutive boot failure
if [ "$VAL" -gt 1 ]; then
    mount -o remount,rw /data 2>/dev/null
    rm -rf /data/apex/active/*
    rm -rf /data/apex/backup/*
    rm -rf /data/dalvik-cache/*
    rm -rf /data/resource-cache/*
    
    echo "$(date '+%Y-%m-%d %H:%M:%S') | APEX CHECK: Selective wipe performed at attempt $VAL" >> "$LOG_FILE"
    echo "Selective wipe performed at attempt $VAL" > /data/local/tmp/last_wipe_log
fi
