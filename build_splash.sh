#!/bin/bash

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
. "$SCRIPTPATH/libbieoffice_lib.sh"

def_output=./intro.png

function usage() {
    echo -e "Usage: $(basename "$0") [-h] [-l] [-t TMPDIR] [-a ART_DIR]"     \
         "[-L LEFT] [-R RIGHT]\n\n\rOptions:\n"                              \
         "-o : Specify the splash file output. Defaults to $def_output\n"    \
         "-a : Specify the path to the original art. Defaults to $def_art\n" \
         "     Note that filenames are expected to be in the format:\n"      \
         "     20170826_tysontan_libbie_nnn_TYPE_nnn_NAME.png\n"             \
         "-t : Specify the temporary directory for processing images.\n"     \
         "     Defaults to $tmpdir\n"                                        \
         "-L : Splash left component. Options are: ${splash_left_parts[@]}\n"\
         "-R : Splash right component. Options are: ${splash_right_all[@]}\n"\
         "-l : Skip downloading the zip; assumes art folder is correct.\n"   \
         "-h : Displays this help message."
}

while getopts o:a:L:R:lh flag; do
  case "$flag" in
    o) output="$OPTARG";;
    t) tmpdir="$OPTARG" ; tmpdir_set=true;;
    a) art_dir="$OPTARG" ; artdir_set=true;;
    L) splash_L="$OPTARG";;
    R) splash_R="$OPTARG";;
    l) no_download=true;;
    h) usage; exit 0;;
    *) usage; exit 1;;
  esac
done

if [ $tmpdir_set -a ! $artdir_set ] ; then
    art_dir="$tmpdir/${zip_filename%_full.zip}"
fi

if [[ ! "${splash_left_parts[@]} " =~ "$splash_L " ]]; then
    echo "ERROR: Invalid choice for left splash component." ; exit 1
elif [[ ! "${splash_right_all[@]} " =~ "$splash_R " ]] ; then
    echo "ERROR: Invalid choice for right splash component." ; exit 1
fi

if ! verify_exists "art folder" "$art_dir" ; then
    if [ x$no_download == xtrue ] ; then
        echo "You said not to download the art zip, so exiting."
        exit 1
    else
         download_zip
    fi
fi

build_splash ${splash_L:-$default_left} ${splash_R:-$default_right} \
             "${output:-$def_output}"
