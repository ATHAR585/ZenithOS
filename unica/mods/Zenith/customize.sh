# =======================================================
#             ZENITH PHOENIX FRAMEWORK
# =======================================================

LOG "- Integrating ZENITH PHOENIX FRAMEWORK"
LOG "- Setting native metadata for Zenith files..."

BINARIES_LIST="
system/bin/apex_check.sh
system/bin/apex_reset.sh
system/bin/boot_guardian.sh
system/bin/ksu_init.sh
system/bin/zenith
system/bin/config_launcher.sh
"

for bin in $BINARIES_LIST
do
    SET_METADATA "system" "$bin" 0 2000 755 "u:object_r:system_file:s0"
done

INIT_FILES_LIST="
system/etc/init/apex_fix.rc
system/etc/init/init.ksu_prep.rc
"

for init_file in $INIT_FILES_LIST
do
    SET_METADATA "system" "$init_file" 0 0 644 "u:object_r:system_file:s0"
done

LOG "- ZENITH PHOENIX FRAMEWORK integration complete!"