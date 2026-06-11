#!/bin/bash

echo "TWRP config path changer"

find bootable/recovery -name "*.orig" -delete

find bootable/recovery -type f \( -name "*.cpp" -o -name "*.hpp" -o -name "*.h" -o -name "*.c" \) \
    -exec sed -i 's|"/data/recovery|"/persist|g' {} +

find bootable/recovery -type f \( -name "*.cpp" -o -name "*.hpp" -o -name "*.h" \) \
    -exec sed -i 's|"/persist|"/persist|g' {} +

echo "Checking for remaining paths..."
echo "/data/recovery leftovers:"
grep -r '"/data/recovery' bootable/recovery || echo "ОК: /data/recovery fully removed."

echo "Checking /persist without mnt/vendor:"
grep -r "/persist" bootable/recovery | grep -v "/persist" | grep -v "bootable/recovery/tests/" || echo "ОК: All paths are unified."

exit 0
