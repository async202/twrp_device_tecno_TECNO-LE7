#!/system/bin/sh

LOG_FILE="/tmp/prepdecrypt.log"
exec > "$LOG_FILE" 2>&1

set -x

echo "=== Launching decrypt preparation ==="
date

mkdir -p /s

SLOT=$(getprop ro.boot.slot_suffix | tr -d '[:space:]\r\n\t ')
echo "Current device slot: '$SLOT'"

SYS_BLOCK="/dev/block/mapper/system$SLOT"
echo "Expected system block: '$SYS_BLOCK'"

PROP_FILE=""

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
        echo "Wait for $SYS_BLOCK to appear... (attempt $i)"
        sleep 1
        i=$((i+1))
    done

    if [ -b "$SYS_BLOCK" ]; then
        echo "Device block $SYS_BLOCK is found. Trying to mount as READ-ONLY..."
        mount -t erofs -o ro "$SYS_BLOCK" /s || mount -t ext4 -o ro "$SYS_BLOCK" /s
        
        if [ $? -eq 0 ]; then
            echo "Mount to /s completed successfully"
            if [ -f "/s/system/build.prop" ]; then
                PROP_FILE="/s/system/build.prop"
            elif [ -f "/s/build.prop" ]; then
                PROP_FILE="/s/build.prop"
            fi
        else
            echo "ERR: Could not mount device block $SYS_BLOCK in /s!"
        fi
    fi
fi

if [ ! -z "$PROP_FILE" ] && [ -f "$PROP_FILE" ]; then
    echo "Extracting system properties from $PROP_FILE..."
    
    PATCHLEVEL=$(grep "ro.build.version.security_patch=" "$PROP_FILE" | cut -d'=' -f2 | head -n1 | tr -d '[:space:]\r ')
    RELEASE=$(grep "ro.build.version.release=" "$PROP_FILE" | cut -d'=' -f2 | head -n1 | tr -d '[:space:]\r ')
    
    echo "Extracted values: PATCHLEVEL='$PATCHLEVEL', RELEASE='$RELEASE'"
    
    if command -v resetprop >/dev/null 2>&1; then
        echo "Using resetprop to bypass init restriction..."
        
        if [ ! -z "$PATCHLEVEL" ]; then
            resetprop ro.build.version.security_patch "$PATCHLEVEL"
        fi
        
        if [ ! -z "$RELEASE" ]; then
            resetprop ro.build.version.release "$RELEASE"
            resetprop ro.build.version.release_or_codename "$RELEASE"
            resetprop ro.vendor.build.version.release "$RELEASE"
        fi
    else
        echo "ERROR: resetprop not found!"
        [ ! -z "$PATCHLEVEL" ] && setprop ro.build.version.security_patch "$PATCHLEVEL"
        [ ! -z "$RELEASE" ] && setprop ro.build.version.release "$RELEASE"
    fi
else
    echo "FATAL: core build.prop file could not be found!"
fi

umount /s 2>/dev/null
rmdir /s 2>/dev/null

setprop tw.decrypt.props.ready true
echo "=== Decrypt preparation done ==="
