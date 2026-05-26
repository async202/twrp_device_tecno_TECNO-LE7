#!/system/bin/sh

# Create temporary mount point
mkdir /s

SLOT=$(getprop ro.boot.slot_suffix)
SYS_BLOCK="/dev/block/mapper/system$SLOT"

if [ -b "$SYS_BLOCK" ]; then
    #  Mount system (ext4 or erofs) as r/o
    mount -t erofs $SYS_BLOCK /s || mount -t ext4 $SYS_BLOCK /s
    # Search patch date in build.prop
    PATCHLEVEL=$(grep "ro.build.version.security_patch=" /s/system/build.prop | cut -d'=' -f2)
    # Additional check for GSI
    if [ -z "$PATCHLEVEL" ]; then
        PATCHLEVEL=$(grep "ro.build.version.security_patch=" /s/build.prop | cut -d'=' -f2)
    fi
    # Spoof sec. patch date
    if [ ! -z "$PATCHLEVEL" ]; then
        setprop ro.build.version.security_patch "$PATCHLEVEL"
    fi
    # Unmount and cleanup
    umount /s
fi

rmdir /s

setprop tw.decrypt.props.ready true
