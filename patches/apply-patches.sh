#!/bin/bash

patch -p1 -d bootable/recovery < device/tecno/TECNO_LE7x/patches/0001-revert-save-settings-file-in-persist.patch

sed -i 's|"/persist/.twrps"|"/mnt/vendor/persist/.twrps"|g' bootable/recovery/data.hpp
sed -i 's|"/persist"|"/mnt/vendor/persist"|g' bootable/recovery/partition.cpp
sed -i 's|"/persist/time/"|"/mnt/vendor/persist/time/"|g' bootable/recovery/partition.cpp
sed -i 's|"/persist/"|"/mnt/vendor/persist/"|g' bootable/recovery/twrp-functions.hpp
sed -i 's|"/persist"|"/mnt/vendor/persist"|g' bootable/recovery/data.cpp

grep -r "/persist" bootable/recovery | grep -v "/mnt/vendor/persist"

exit 0
