#!/system/bin/sh

LOG_FILE="/tmp/prepdecrypt.log"
exec > "$LOG_FILE" 2>&1
set -x

echo "=== Launching decrypt preparation ==="
date

set_property() {
    local prop_name="$1"
    local prop_value="$2"
    
    [ -z "$prop_value" ] && return 0

    if command -v resetprop >/dev/null 2>&1; then
        resetprop "$prop_name" "$prop_value"
    else
        setprop "$prop_name" "$prop_value"
    fi
}

mkdir -p /s

SLOT=$(getprop ro.boot.slot_suffix | tr -d '[:space:]\r\n\t ')
SYS_BLOCK="/dev/block/mapper/system$SLOT"
PROP_FILE=""

echo "Current device slot: '$SLOT' | Expected block: '$SYS_BLOCK'"


SEARCH_PATHS="/system_root/system/build.prop /system/system/build.prop /system/build.prop /system_root/build.prop"
for path in $SEARCH_PATHS; do
    if [ -f "$path" ]; then
        echo "Found build.prop already mounted by TWRP at: $path"
        PROP_FILE="$path"
        break
    fi
done


if [ -z "$PROP_FILE" ]; then
    echo "build.prop not found in active TWRP paths. Waiting for block device..."
    
    i=1
    while [ $i -le 10 ]; do
        if [ -b "$SYS_BLOCK" ]; then
            echo "Success: Block device $SYS_BLOCK found on attempt $i"
            break
        fi
        echo "Waiting for $SYS_BLOCK to appear... (attempt $i/10)"
        sleep 1
        i=$((i+1))
    done

    if [ -b "$SYS_BLOCK" ]; then
        echo "Device block found. Trying to mount as READ-ONLY..."
        if mount -t erofs -o ro "$SYS_BLOCK" /s || mount -t ext4 -o ro "$SYS_BLOCK" /s; then
            echo "Mount to /s completed successfully"
            if [ -f "/s/system/build.prop" ]; then
                PROP_FILE="/s/system/build.prop"
            elif [ -f "/s/build.prop" ]; then
                PROP_FILE="/s/build.prop"
            fi
        else
            echo "ERROR: Could not mount device block $SYS_BLOCK in /s!"
        fi
    fi
fi


if [ -n "$PROP_FILE" ] && [ -f "$PROP_FILE" ]; then
    echo "Extracting system properties from $PROP_FILE..."
    
    PATCHLEVEL=$(grep "ro.build.version.security_patch=" "$PROP_FILE" | cut -d'=' -f2 | head -n1 | tr -d '[:space:]\r ')
    RELEASE=$(grep "ro.build.version.release=" "$PROP_FILE" | cut -d'=' -f2 | head -n1 | tr -d '[:space:]\r ')
    
    echo "Extracted values: PATCHLEVEL='$PATCHLEVEL', RELEASE='$RELEASE'"
    

    set_property "ro.build.version.security_patch"      "$PATCHLEVEL"
    set_property "ro.build.version.release"             "$RELEASE"
    set_property "ro.build.version.release_or_codename" "$RELEASE"
    set_property "ro.vendor.build.version.release"      "$RELEASE"
else
    echo "FATAL: Core build.prop file could not be found!"
fi

umount /s 2>/dev/null
rmdir /s 2>/dev/null


TWRPS_FILE="/data/recovery/.twrps"

if [ -f "$TWRPS_FILE" ]; then
    echo "TWRP settings file detected. Restoring permissions and SELinux context..."
    chown root:root "$TWRPS_FILE"
    chmod 0666 "$TWRPS_FILE"
    restorecon "$TWRPS_FILE"
else
    echo "Notice: $TWRPS_FILE not found (possibly clean data), skipping fix."
fi


setprop tw.decrypt.props.ready true
echo "=== Decrypt preparation done ==="
