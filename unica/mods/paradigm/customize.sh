# Now Brief
ADD_TO_WORK_DIR "pa3qzcx" "system" "system/priv-app/SamsungSmartSuggestions/SamsungSmartSuggestions.apk"
ADD_TO_WORK_DIR "pa3qzcx" "system" "system/priv-app/SamsungSmartSuggestions/oat"
# HACK [
# Samsung has released an update for the Smart suggestions app in March 2026.
# The versioning of the "basic-global-release" flavor differs from the "full-global-release" one.
# This is done on purpose: Samsung uses a lower version number to avoid installing this variant
# on unsupported devices by triggering the downgrade check in PM. To avoid users updating to the
# "non-AI" app, let's fake the versionCode so that it matches the latest available version.
DECODE_APK "system" "system/priv-app/SamsungSmartSuggestions/SamsungSmartSuggestions.apk"
LOG "- Patching versionCode in SamsungSmartSuggestions.apk"
EVAL "sed -i \"s/710500000/711100100/g\" \"$APKTOOL_DIR/system/priv-app/SamsungSmartSuggestions/SamsungSmartSuggestions.apk/apktool.yml\""
# ]
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_FRAMEWORK_SUPPORT_PERSONALIZED_DATA_CORE" "TRUE"

# AI
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_CAMERA_CONFIG_IS_GPPM_1_0_ENABLED" "TRUE"
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_CAMERA_CONFIG_WINE_DETECTOR" "V1_SNAP_CPU"
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_CAMERA_SUPPORT_GALLERY_LR" "TRUE"
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_LOCKSCREEN_CONFIG_WALLPAPER_STYLE" "VIDEO,COVER_MP4,GENWEATHER,FLIPSUIT_LOCK"
SET_FLOATING_FEATURE_CONFIG "SEC_FLOATING_FEATURE_MMFW_SUPPORT_AI_MASTERINGNET" "TRUE"

# Sounds
FOLDER_LIST="
system/media/audio/notifications
system/media/audio/ringtones
system/media/audio/ui
"
for folder in $FOLDER_LIST
do
    DELETE_FROM_WORK_DIR "system" "$folder"
    ADD_TO_WORK_DIR "pa3qzcx" "system" "$folder"
done