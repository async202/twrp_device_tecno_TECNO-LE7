#!/system/bin/sh

LOG_FILE="/tmp/prepdecrypt.log"
exec > "$LOG_FILE" 2>&1

# Enable trace
set -x

echo "=== Launching decrypt preparation ==="
date

# Create temporary mount point
mkdir /s

SLOT=$(getprop ro.boot.slot_suffix | tr -d '[:space:]\r\n\t ')
echo "Current device slot: '$SLOT'"

SYS_BLOCK="/dev/block/mapper/system$SLOT"
echo "Expected system block: '$SYS_BLOCK'"

for i in $(seq 1 10); do
    if [ -b "$SYS_BLOCK" ]; then
        echo "Success: Block device $SYS_BLOCK found on attempt $i"
        break
    fi
    echo "Wait for $SYS_BLOCK to appear... (attempt $i)"
    sleep 1
done

if [ -b "$SYS_BLOCK" ]; then
    echo "Device block $SYS_BLOCK is found. Trying to mount..."
    
    #  Mount system (ext4 or erofs) as r/o
    mount -t erofs $SYS_BLOCK /s || mount -t ext4 $SYS_BLOCK /s


if [ $? -eq 0 ]; then
        echo "Mount to /s completed successfully"
        echo "Searching for patch date in /s/system/build.prop..."
        
        PATCHLEVEL=$(grep "ro.build.version.security_patch=" /s/system/build.prop | cut -d'=' -f2 | head -n1 | tr -d '[:space:]\r ')
        
        if [ -z "$PATCHLEVEL" ]; then
            echo "Patch is not found in /s/system/build.prop, checking GSI-specific path (/s/build.prop)..."
            PATCHLEVEL=$(grep "ro.build.version.security_patch=" /s/build.prop | cut -d'=' -f2 | head -n1 | tr -d '[:space:]\r ')
        fi
        
        echo "PATCHLEVEL search result: '$PATCHLEVEL'"
        
        if [ ! -z "$PATCHLEVEL" ]; then
            echo "Setting property ro.build.version.security_patch to $PATCHLEVEL"
            setprop ro.build.version.security_patch "$PATCHLEVEL"
        else
            echo "ERROR: PATCHLEVEL is empty!"
        fi
        
        umount /s
    else
        echo "ERR: Could not mount device block $SYS_BLOCK in /s!"
    fi
else
    echo "FATAL: Block device $SYS_BLOCK does not exist even after timeout!"
fi

rmdir /s
setprop tw.decrypt.props.ready true
echo "=== Decrypt preparation done ==="
