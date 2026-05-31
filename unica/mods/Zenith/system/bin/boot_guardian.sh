#!/system/bin/sh
# Zenith Boot Guardian - KSU Edition (with Invisible Kernel Protection)
# Created by @szucsy92 & @A1X31

FILE="/data/local/tmp/boot_attempts"
MOD_DIR="/data/adb/modules"
PSTORE_DIR="/sys/fs/pstore"
LOG_FILE="/data/local/tmp/zenith_guardian.log"

mount -o remount,rw /data 2>/dev/null

[ ! -f "$FILE" ] && echo 0 > "$FILE"
VAL=$(cat "$FILE")

# --- INVISIBLE KERNEL PANIC DETECTOR ---
KERNEL_CRASH=0
if [ -d "$PSTORE_DIR" ]; then
    if grep -qiE "kernel panic|fatal exception|Call trace|Kernel BUG|Unable to mount root fs" "$PSTORE_DIR"/* 2>/dev/null; then
        KERNEL_CRASH=1
    fi
fi

# Ha kernel hiba volt, azonnal ugrunk a "Recovery" szinthez közeli értékre
# Ez garantálja, hogy a hibás modul ne tudjon újra betölteni
if [ "$KERNEL_CRASH" -eq 1 ]; then
    NEW_VAL=4

    echo "$(date '+%Y-%m-%d %H:%M:%S') | KERNEL PANIC DETECTED - DISABLING ALL MODULES" >> "$LOG_FILE"

    # Vészhelyzeti SAFE MODE
    # Minden modul letiltása boot stabilitás érdekében
    for mod in "$MOD_DIR"/*; do
        [ -d "$mod" ] && touch "$mod/disable"
    done
else
    NEW_VAL=$((VAL + 1))
fi
# ---------------------------------------

echo "$NEW_VAL" > "$FILE"

# ====================================================================
# DO NOT MODIFY THE SYNTAX BELOW! THE ZENITH MANAGER RELIES ON IT.
# ====================================================================

# Action: Wipe APEX cache and disable problematic modules (Level 1)
# (Zenith Manager targets this line for APEX trigger)
if [ $NEW_VAL -gt 1 ]; then

    echo "$(date '+%Y-%m-%d %H:%M:%S') | LEVEL 1 PROTECTION TRIGGERED" >> "$LOG_FILE"

    # Safe mode jellegû védelem
    for mod in "$MOD_DIR"/*; do
        [ -d "$mod" ] && touch "$mod/disable"
    done

    rm -rf /data/apex/active/*
    rm -rf /data/apex/backup/*
    rm -rf /data/dalvik-cache/*
    rm -rf /data/resource-cache/*
fi

# Action: Reboot to Recovery for manual intervention (Level 2)
# (Zenith Manager targets this line for BOOT limit)
if [ $NEW_VAL -gt 4 ]; then

    echo "$(date '+%Y-%m-%d %H:%M:%S') | LEVEL 2 PROTECTION - REBOOTING TO RECOVERY" >> "$LOG_FILE"

    echo 0 > "$FILE"
    reboot recovery
fi