#!/bin/bash

cd ./bootable/recovery
patch -p1 < ../../device/tecno/TECNO_LE7x/patches/0001-revert-save-settings-file-in-persist.patch
cd ../..

exit 0
