#!/system/bin/sh

FILE="/data/local/tmp/boot_attempts"
LOG_FILE="/data/local/tmp/zenith_guardian.log"

wait_for_prop() {
    local PROP="$1"
    local EXPECTED="$2"

    while true; do
        CUR=$(getprop "$PROP")

        if [ "$CUR" = "$EXPECTED" ]; then
            return 0
        fi

        sleep 2
    done
}

# Várunk a teljes rendszer bootra
wait_for_prop sys.boot_completed 1

# Extra stabilizáció
sleep 10

# Counter reset
echo 0 > "$FILE"

# Log
echo "$(date '+%Y-%m-%d %H:%M:%S') | BOOT SUCCESS - COUNTER RESET" >> "$LOG_FILE"
