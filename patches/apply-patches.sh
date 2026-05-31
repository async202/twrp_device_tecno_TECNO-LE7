#!/bin/bash

# Torturing TWRP source code aka replacing /data/recovery to /data/media/TWRP beacuse this shit does not want to write its own .twrps in /data/recovery, only read

if [ -d "bootable/recovery" ]; then
    echo "-> Replacing /data/recovery to /data/media/TWRP in sources..."
    
    find bootable/recovery -type f \( -name "*.cpp" -o -name "*.h" \) -exec sed -i 's|/data/recovery|/data/media/TWRP|g' {} +
    
    echo "-> Замена успешно выполнена!"
fi
