#!/bin/bash

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
. "$SCRIPTPATH/libbieoffice_lib.sh"

function usage() {
    echo -e "Usage: $(basename "$0") [-hfl] [-o INSTALL_TO] [-a ART_DIR]"    \
         "[-t TMPDIR] [-b BACKUP_DEST] [-r ARCHIVE] [-L LEFT] [-R RIGHT]\n\n"\
         "\rOptions:\n"                                                      \
         "-o : Specify the installation root. Defaults to $def_install\n"    \
         "-a : Specify the path to the original art. Defaults to $def_art\n" \
         "     Note that filenames are expected to be in the format:\n"      \
         "     20170826_tysontan_libbie_nnn_TYPE_nnn_NAME.png\n"             \
         "-f : Forces the script to regenerate all scaled/cropped images\n"  \
         "-t : Specify the temporary directory for processing images.\n"     \
         "     Defaults to $tmpdir\n"                                        \
         "-b : Back up existing theme files to a specified archive.\n"       \
         "-r : Restore theme files from a specified archive\n"               \
         "-L : Splash left component. Options are: ${splash_left_parts[@]}\n"\
         "-R : Splash right component. Options are: ${splash_right_all[@]}\n"\
         "-l : Skip downloading the zip; assumes art folder is correct.\n"   \
         "-h : Displays this help message."
}

##############################################################################

while getopts o:t:a:fb:r:L:R:lh flag; do
  case "$flag" in
    o) installdir="$OPTARG";;
    t) tmpdir="$OPTARG" ; tmpdir_set=true;;
    a) art_dir="$OPTARG" ; artdir_set=true;;
    f) force_regen=true;;
    b) backup="$OPTARG";;
    r) restore="$OPTARG";;
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

if [ "$backup" -a "$restore" ] ; then
    echo "ERROR: specify one of either backup or restore."
    exit 1
fi

if [ "$backup" ] ; then backup_files "$backup" ; exit $? ; fi
verify_writable "installation root" "$installdir" || exit 1
if [ "$restore" ] ; then restore_files "$restore" ; exit $? ; fi

if [[ ! "${splash_left_parts[@]} " =~ "$splash_L " ]]; then
    echo "ERROR: Invalid choice for left splash component." ; exit 1
elif [[ ! "${splash_right_all[@]} " =~ "$splash_R " ]] ; then
    echo "ERROR: Invalid choice for right splash component." ; exit 1
fi

if ! verify_exists "art folder" "$art_dir" INFO ; then
    if [ x$no_download == xtrue ] ; then
        echo "You said not to download the art zip, so exiting."
        exit 1
    else
         download_zip
    fi
fi

verify_tmpdir "temp folder" "$tmpdir" || exit 1

for app in ${app_names[@]} ; do
    app_icons[$app]=$app
    zip_apps[$app]=$app
done

declare -a mkdirs
[ "$write_full" == true ] && full_dir=full
for dim in ${color_sizes[@]} $full_dir ; do
    mkdirs+=("$tmpdir/color/autotrim/$dim")
    mkdirs+=("$tmpdir/color/squarefill/$dim")
done

for dim in ${blackwhite_sizes[@]} $full_dir ; do
    mkdirs+=("$tmpdir/blackwhite/autotrim/$dim")
    mkdirs+=("$tmpdir/blackwhite/squarefill/$dim")
done

for dim in ${res_sizes[@]} $full_dir ; do
    mkdirs+=("$tmpdir/color/crop/$dim")
    mkdirs+=("$tmpdir/blackwhite/crop/$dim")
done

mkdir -p "${mkdirs[@]}"

generate_icons color ${color_sizes[@]}
generate_icons blackwhite ${blackwhite_sizes[@]}

build_splash ${splash_L:-$default_left} ${splash_R:-$default_right} \
             "$tmpdir/intro.png"

for mode in color blackwhite ; do
    mkdir -p "$tmpdir/$mode/res"
    for dim in ${zip_app_sizes[@]} ; do
        for app in ${!zip_apps[@]} ; do
            cp -f "$tmpdir/$mode/crop/$dim/${zip_apps[$app]}.png" \
                  "$tmpdir/$mode/res/${app}${dim}.png"
        done
    done

    for dim in ${ext_sizes[@]} ; do
        for ext in ${!zip_ext[@]} ; do
            cp -f "$tmpdir/$mode/crop/$dim/${zip_ext[$ext]}.png" \
                  "$tmpdir/$mode/res/${ext}_${dim}_8.png"
        done
    done
done

cp "$tmpdir/intro.png" "$installdir/usr/lib/libreoffice/program/intro.png"

install_icon_group color ${color_themes[@]}
install_icon_group blackwhite ${blackwhite_themes[@]}

modify_zips color ${color_zips[@]}
modify_zips blackwhite ${blackwhite_zips[@]}
