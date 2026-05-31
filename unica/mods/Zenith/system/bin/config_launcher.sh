#!/system/bin/sh
# ==============================================================================
#  Z E N I T H   C O N F I G   L A U N C H E R
#  Priority: STAGING > PERSISTENT (DATA) > SYSTEM (ORIGINAL)
# ==============================================================================

STAGING="/data/local/tmp/zenith_staging"
PERSISTENT="/data/adb/service.d"
FALLBACK="/system/bin"
TARGET="$1"

# 1. Prioritás: Ideiglenes staging (azonnali teszteléshez)
if [ -f "$STAGING/$TARGET.sh" ]; then
    exec /system/bin/sh "$STAGING/$TARGET.sh"

# 2. Prioritás: Véglegesített adatok (Apply Changes után ide kerülnek)
elif [ -f "$PERSISTENT/$TARGET.sh" ]; then
    exec /system/bin/sh "$PERSISTENT/$TARGET.sh"

# 3. Prioritás: Gyári rendszerfájl (ha nincs módosítás)
else
    exec /system/bin/sh "$FALLBACK/$TARGET.sh"
fi
