#!/system/bin/sh

LOG_FILE="/tmp/prepdecrypt.log"
exec > "$LOG_FILE" 2>&1

# Enable trace
set -x

echo "=== Launching decrypt preparation ==="
date

# Create temporary mount point
mkdir /s

SLOT=$(getprop ro.boot.slot_suffix)
echo "Current device slot: '$SLOT'"

SYS_BLOCK="/dev/block/mapper/system$SLOT"
echo "Expected system block: $SYS_BLOCK"

if [ -b "$SYS_BLOCK" ]; then
    echo "Device block $SYS_BLOCK is found. Trying to mount..."
    
    #  Mount system (ext4 or erofs) as r/o
    mount -t erofs $SYS_BLOCK /s || mount -t ext4 $SYS_BLOCK /s
    
    # Check mount status
    if [ $? -eq 0 ]; then
        echo "Mount to /s completed successfully"
    else
        echo "ERR: Could not mount device block $SYS_BLOCK in /s!"
    fi

    # Search patch date in build.prop
    echo "Searching for patch date in /s/system/build.prop..."
    PATCHLEVEL=$(grep "ro.build.version.security_patch=" /s/system/build.prop | cut -d'=' -f2)
    
    # Additional check for GSI
    if [ -z "$PATCHLEVEL" ]; then
        echo "Patch is not found in /s/system/build.prop, checking GSI-specific path (/s/build.prop)..."
        PATCHLEVEL=$(grep "ro.build.version.security_patch=" /s/build.prop | cut -d'=' -f2)
    fi
    
    echo "PATCHLEVEL search result: '$PATCHLEVEL'"

    # Spoof sec. patch date
    if [ ! -z "$PATCHLEVEL" ]; then
        echo "Setting property ro.build.version.security_patch in $PATCHLEVEL"
        setprop ro.build.version.security_patch "$PATCHLEVEL"
    else
        echo "WARN: PATCHLEVEL is empty, spoof failed."
    fi
    
    # Unmount and cleanup
    echo "Unmounting /s..."
    umount /s
else
    echo "FATAL: Block device $SYS_BLOCK does not exist!"
fi

rmdir /s

echo "Setting decrypt props ready flag..."
setprop tw.decrypt.props.ready true

echo "=== Decrypt preparation done ==="
