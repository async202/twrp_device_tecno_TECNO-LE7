#!/bin/bash
set -e

PATCHES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

shopt -s nullglob

for project_folder in $(cd "$PATCHES_DIR"; echo *); do
    [ "$project_folder" == "apply-patches.sh" ] && continue
    [ ! -d "$PATCHES_DIR/$project_folder" ] && continue

    target_path="$(tr _ / <<<$project_folder | sed -e 's;platform/;;g')"
    
    [ "$target_path" == "build" ] && target_path=build/make

    echo "-> Processing: $target_path"

    if [ ! -d "$target_path" ]; then
        echo "[WARN] $target_path not found in source. Skipping..."
        continue
    fi

    pushd "$target_path" > /dev/null
    
    git reset --hard > /dev/null
    git clean -fdx > /dev/null

    for patch in "$PATCHES_DIR/$project_folder"/*.patch; do
        echo "Applying: $(basename "$patch")"
        
        if git apply --check "$patch" 2>/dev/null; then
            git apply "$patch"
            echo "[SUCCESS] Patch applied via git apply"
        elif patch -f -p1 --dry-run < "$patch" > /dev/null; then
            patch -f -p1 < "$patch"
            echo "[SUCCESS] Patch applied via fallback patch"
        else
            echo "[ERR] Could not apply patch $patch"
            exit 1
        fi
    done
    
    popd > /dev/null
done
