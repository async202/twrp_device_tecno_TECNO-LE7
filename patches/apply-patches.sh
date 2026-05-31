#!/bin/bash

SRC_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../../../../" && pwd )"
PATCHES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd "$SRC_ROOT"

if [ -f "bootable/recovery/data.cpp" ]; then
    echo "-> [SED] Changing config into data.cpp..."
    sed -i 's|"/data/recovery/.twrps"|"/data/media/TWRP/.twrps"|g' bootable/recovery/data.cpp
fi

