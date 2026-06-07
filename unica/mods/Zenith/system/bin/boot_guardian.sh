#!/system/bin/sh
# Zenith Boot Guardian - Ultimate Edition (Hardware Switch & Smart Logic)
# Created by @szucsy92 & @A1X31

FILE="/data/local/tmp/boot_attempts"
MOD_DIR="/data/adb/modules"
PSTORE_DIR="/sys/fs/pstore"
LAST_KMSG="/proc/last_kmsg"
LOG_FILE="/data/local/tmp/zenith_guardian.log"

mount -o remount,rw /data 2>/dev/null

# ==============================================================================
# 1. HARDWARE KILL SWITCH (BUFFER FIX)
# ==============================================================================
getevent -qc 8 > /data/local/tmp/keys_pressed.log &
GETEVENT_PID=$!
sleep 4
kill -9 $GETEVENT_PID 2>/dev/null

if grep -iE "0001 0072|0001 0073" /data/local/tmp/keys_pressed.log 2>/dev/null; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') | EMERGENCY: Physical Volume Key detected! Forcing Recovery." >> "$LOG_FILE"
    rm -f /data/local/tmp/keys_pressed.log
    echo 0 > "$FILE"
    reboot recovery
    exit 0
fi
rm -f /data/local/tmp/keys_pressed.log
# ==============================================================================

[ ! -f "$FILE" ] && echo 0 > "$FILE"
VAL=$(cat "$FILE")

# ==============================================================================
# 2. INVISIBLE KERNEL PANIC DETECTOR (SAMSUNG SUPPORT)
# ==============================================================================
KERNEL_CRASH=0
if grep -qiE "kernel panic|fatal exception|Call trace|Kernel BUG|Unable to mount root fs|EXT4-fs error|F2FS-fs error" "$PSTORE_DIR"/* "$LAST_KMSG" 2>/dev/null; then
    KERNEL_CRASH=1
fi

if [ "$KERNEL_CRASH" -eq 1 ]; then
    NEW_VAL=4
    echo "$(date '+%Y-%m-%d %H:%M:%S') | KERNEL PANIC DETECTED - FORCING SMART DISABLE" >> "$LOG_FILE"
    
    # Intelligens tiltás: Csak a legutoljára módosított (telepített) modult lõjük ki
    LATEST_MOD=$(ls -td "$MOD_DIR"/*/ 2>/dev/null | head -n 1)
    if [ -n "$LATEST_MOD" ]; then
        touch "${LATEST_MOD}disable"
        echo "-> SMART DISABLE: $(basename "$LATEST_MOD") disabled." >> "$LOG_FILE"
    fi
else
    NEW_VAL=$((VAL + 1))
fi
# ==============================================================================

echo "$NEW_VAL" > "$FILE"

# ====================================================================
# DO NOT MODIFY THE SYNTAX BELOW! THE ZENITH MANAGER RELIES ON IT.
# ====================================================================

# Action: Wipe APEX cache and dalvik (Level 1)
# (Zenith Manager targets this line for APEX trigger)
if [ $NEW_VAL -gt 1 ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') | LEVEL 1 PROTECTION TRIGGERED (Cache Wipe)" >> "$LOG_FILE"
    rm -rf /data/apex/active/*
    rm -rf /data/apex/backup/*
    rm -rf /data/dalvik-cache/*
    rm -rf /data/resource-cache/*
fi

# Action: Reboot to Recovery for manual intervention (Level 2)
# (Zenith Manager targets this line for BOOT limit)
if [ $NEW_VAL -gt 4 ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') | LEVEL 2 PROTECTION: Rebooting to Recovery" >> "$LOG_FILE"
    echo 0 > "$FILE"
    reboot recovery
fi
