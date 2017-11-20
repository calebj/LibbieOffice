#!/bin/bash

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
. "$SCRIPTPATH/libbieoffice_lib.sh"

out_dir=./trimmed
mkdir -p trimmed
mkdir -p "$out_dir/"{autotrim,squarefill,crop}"/full"

download_zip

for orig in "$art_dir/20170826_tysontan_libbie_001_color_"*.png ; do
    out="${orig##*_}"
    name=${out%.png}
    crop=${crops[$name]:-none}
    write_full=true
    res_sizes=()  # hacky override
    echo "${out}... "
    generate_icon $name color "$out_dir" true true $crop
done
echo "done."
