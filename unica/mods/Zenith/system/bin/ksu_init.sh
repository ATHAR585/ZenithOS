#!/system/bin/sh

SRC="/system/usr/share/ksu_modules/adb"
DEST="/data/adb"

I=0
while [ ! -d "$DEST" ] && [ $I -lt 15 ]; do
    sleep 2
    I=$((I+1))
done

[ ! -d "$DEST" ] && exit 1

for mod in "$SRC"/*; do
    if [ -d "$mod" ]; then

        name=$(basename "$mod")

        if [ "$name" = "zygisksu" ] || [ "$name" = "magic_mount_rs" ] || [ -d "$DEST/$name/zygisk" ]; then
            if [ -d "$DEST/$name" ]; then
                continue
            fi
        fi

        cp -af "$mod" "$DEST/"

        touch "$DEST/$name/update"
        rm -f "$DEST/$name/disable"
        rm -f "$DEST/$name/skip_mount"
    fi
done
