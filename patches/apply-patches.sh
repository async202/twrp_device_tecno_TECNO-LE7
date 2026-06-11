#!/bin/bash

echo "TWRP config path changer"

patch -p1 -d bootable/recovery < device/tecno/TECNO_LE7x/patches/0001-revert-save-settings-file-in-persist.patch

exit 0
