#!/bin/bash

patch -p1 -d bootable/recovery < device/tecno/TECNO_LE7x/patches/0001-revert-save-settings-file-in-persist.patch

find bootable/recovery -name "*.orig" -delete

find bootable/recovery -type f \( -name "*.cpp" -o -name "*.hpp" -o -name "*.h" \) -exec sed -i 's|"/persist|"/mnt/vendor/persist|g' {} +

find bootable/recovery -name "variables.h" -exec sed -i 's|#define TW_STORAGE_PATH.*"/data/recovery/"|#define TW_STORAGE_PATH             "/mnt/vendor/persist/"|g' {} +

echo "Checking for remaining paths..."
grep -r "/persist" bootable/recovery | grep -v "/mnt/vendor/persist" | grep -v "bootable/recovery/tests/"

exit 0
