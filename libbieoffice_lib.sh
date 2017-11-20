#!/bin/bash

SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"

if ((BASH_VERSINFO[0] < 4)); then
    echo "Sorry, you need at least bash 4.0 to run this script." >&2
    exit 1
fi

zip_download="https://www.dropbox.com/s/77r848yux6oof8g/20170826_tysontan_libbie_full.zip?dl=1"
zip_filename=20170826_tysontan_libbie_full.zip
zip_md5=bfa18271cf413c17db04c1b775ed3571

# defaults
def_art=TMPDIR/${zip_filename%_full.zip}
def_install=/
def_tmp=/tmp/libbieoffice_mod
tmpdir="$def_tmp"
installdir="$def_install"
art_dir="$tmpdir/${zip_filename%_full.zip}"
write_full=false
force_regen=false


# Values for various sizes and themes.
color_sizes=(32 48 128 256 512)
blackwhite_sizes=(22 24 32 48 256 512)
res_sizes=(16 32 48 96 128)
ext_sizes=(16 32 48 96)
color_themes=(gnome hicolor)
blackwhite_themes=(HighContrast)
color_zips=(galaxy breeze breeze_dark tango)
blackwhite_zips=(hicontrast)
zip_app_sizes=(128)

app_names=(base calc draw impress math writer)
process_names=("${app_names[@]}" blank)
splash_left_parts=(libbie libre)
splash_right_parts=(blank 5)

default_left=libbie
default_right=34view

# Though the color and B/W versions are slightly different, crop them the same
declare -A crops=([base]=1508x1508+864+596 [blank]=1428x1428+424+328
                  [calc]=1191x1191+738+599 [draw]=1392x1392+138+194
                  [impress]=1800x1800+583+206 [math]=1232x1232+520+268
                  [writer]=1336x1336+556+416 ) \
           splash_crops=([34view]=1610x1582+254+247 [front]=2234x2375+91+108)\
           app_icons=([main]=blank [startcenter]=blank) \
           mime_icons=([database]=base [drawing]=draw
                       [formula]=math [spreadsheet]=calc
                       [presentation]=impress [text]=writer) \
           zip_ext=([odb]=base [odf]=math [odg]=draw [odm]=blank
                    [odp]=impress [ods]=calc [odt]=writer [otg]=draw
                    [otp]=impress [ots]=calc [ott]=writer) \
           zip_apps=([mainapp]=blank)

splash_right_all=(${!splash_crops[@]} ${splash_right_parts[@]})

function find_original() {
    echo "$(ls "$art_dir/20170826_tysontan_libbie_"*"${1}_"*"_${2}.png")"
}

function download_zip() {
    verify_tmpdir "temp folder" "$tmpdir"

    if [ -e "$tmpdir/$zip_filename" ] && \
       [[ "$(md5sum < "$tmpdir/$zip_filename")" =~ $zip_md5 ]]; then
       echo "Zip already downladed."
    else
        echo "Downloading art zip from dropbox..."
        wget -c -nv --show-progress "$zip_download" -O "$tmpdir/$zip_filename"
    fi

    echo "Extracting..."
    unzip -oqd "$tmpdir" "$tmpdir/$zip_filename"
    art_dir="$tmpdir/${zip_filename%_full.zip}"
}

function generate_icon() {
    icon_name=$1
    mode=$2
    dest="$3"
    autotrim=$4
    squarefill=$5
    crop=$6
    shift 6
    trim_sizes=($@)

    out="${icon_name}.png"
    orig="$(find_original $mode $icon_name)"

    declare -a out_seq
    function set_output_seq() {
        out_seq=()
        subdir=$1 ; max=$2 ; shift 2

        for dim in $@ ; do
            destpath="$dest/$subdir/$dim/$out"

            if [ $dim == full ] ; then
                out_seq=("${out_seq[@]}" \( -write "$destpath" \))
                continue
            elif [ ${dim/x} == $dim ] ; then
                dim=${dim}x${dim}
            fi

            resize_to=$dim
            [ "$max" == true ] && resize_to+="^"
            out_seq=("${out_seq[@]}" \( +clone -resize $resize_to -extent $dim
                     -write "$destpath" +delete \) )
        done

        if [ "$write_full" == true ] ; then
            out_seq=("${out_seq[@]}" \( -write "$dest/$subdir/full/$out" \) )
        fi
    }

    if [ "$autotrim" == true ] ; then
        coords=($(convert "$orig" -format "%w,%h " -write info: \
                -background white -splice 0x1 -fuzz 10% -trim -format \
                "%w,%h %[fx:int(w/2)],%[fx:int(0.98*h)] 0,%[fx:int(0.96*h)]" \
                info:))
        set_output_seq autotrim false ${trim_sizes[@]}
        autotrim_cmd=(-fill black -draw "rectangle ${coords[3]} ${coords[1]}"
                      -fill none -fuzz 10% -draw "matte ${coords[2]} floodfill"
                      -trim -gravity center -background none "${out_seq[@]}")

        if [ "$squarefill" == true ] ; then
            set_output_seq squarefill true ${trim_sizes[@]}
            autotrim_cmd=("${autotrim_cmd[@]}" "${out_seq[@]}")
        fi
    fi

    if [ "$crop" != none ] ; then
        set_output_seq crop false ${res_sizes[@]}
        crop_cmd=(-gravity NorthWest -crop $crop "${out_seq[@]}")
    fi

    convert "$orig" -write mpr:original \
            \( mpr:original "${autotrim_cmd[@]}" \) +delete \
            \( mpr:original "${crop_cmd[@]}" \) null:

    return $?
}

function generate_icons() {
    kind=$1 ; shift
    echo "Generating $kind icons:"

    for icon_name in ${process_names[@]} ; do
        dest="$tmpdir/$kind"
        ok_file="$dest/.generated_$icon_name"

        echo -n " - ${icon_name}... "

        if [ -e "$ok_file" -a "$force_regen" != true ] ; then
            echo "already exists."
        else
            crop=${crops[$icon_name]:-none}
            generate_icon $icon_name $kind "$dest" true true $crop $@ && \
            touch "$ok_file" && echo "ok." || echo "error!"
        fi
    done
}

function modify_zip() {
    zip="$(readlink -f "$1")"
    resdir="$2"

    # zip is stupid for not having -C like tar.
    pushd "$resdir" > /dev/null
    zip -qr "$zip" res
    ret=$?
    popd > /dev/null
    return $ret
}

function modify_zips() {
    mode=$1 ; shift
    resdir="$tmpdir/$mode/"

    echo "Modifying $mode theme zips..."

    for theme in $@ ; do
        echo -n " - $theme... "
        zip="$installdir/usr/lib/libreoffice/share/config/images_${theme}.zip"
        if [ ! -e "$zip" ] ; then
            echo "not found."
            continue
        fi
        modify_zip "$zip" "$resdir" && echo "ok." || echo "error!"
    done
}

function install_icons() {
    src="$tmpdir/$1/autotrim"
    themedir="$2"
    shift 2

    mkdirs=()
    for dim in $@ ; do
        mkdirs+=("$themedir/${dim}x${dim}/mimetypes"
                 "$themedir/${dim}x${dim}/apps")
    done
    mkdir -p "${mkdirs[@]}"

    for app in ${!app_icons[@]} ; do
        target="apps/libreoffice-${app}"
        rm -f "$themedir/scalable/${target}.svg"

        for dim in $@ ; do
            [ -d "$themedir/${dim}x${dim}" ] || continue
            icon_name=${app_icons[$app]}
            cp -f "$src/$dim/${icon_name}.png" \
                  "$themedir/${dim}x${dim}/${target}.png"
        done
    done

    for mimetype in ${!mime_icons[@]} ; do
        target="mimetypes/libreoffice-oasis-${mimetype}"
        rm -f "$themedir/scalable/${target}.svg"

        for dim in $@ ; do
            [ -d "$themedir/${dim}x${dim}" ] || continue
            icon_name=${mime_icons[$mimetype]}
            cp -f "$src/$dim/${icon_name}.png" \
                  "$themedir/${dim}x${dim}/${target}.png"
        done
    done
}

function install_icon_group() {
    mode=$1
    shift

    if [ $mode == color ] ; then sizes=("${color_sizes[@]}")
    elif [ $mode == blackwhite ] ; then sizes=("${blackwhite_sizes[@]}") ; fi

    echo "Installing $mode icons..."
    for theme in $@ ; do
        themedir="$installdir/usr/share/icons/$theme"
        echo -n " - $theme... "

        if [ ! -d "$themedir" ] ; then
            echo "not found."
            continue
        fi

        install_icons $mode "$themedir" ${sizes[@]}
        echo "ok."
    done
}

function backup_files() {
    archive="$1"
    [ -d "$archive" ] && archive+=/libbieoffice_backup_$(date +%s).tgz
    if [ -e "$archive" ] ; then
        echo "ERROR: backup destination ($archive) already exists!"
        return 1
    fi
    verify_writable "backup target" "$(dirname $archive)" || return 1

    backup_list=(/usr/lib/libreoffice/program/intro.png)

    for theme in ${blackwhite_themes[@]} ; do
        themedir="/usr/share/icons/$theme"
        for app in ${!app_icons[@]} ; do
            target="apps/libreoffice-${app}"
            backup_list+=("$themedir/scalable/${target}.svg")
            for dim in ${blackwhite_sizes[@]} ; do
                backup_list+=("$themedir/${dim}x${dim}/${target}.png")
            done
        done
        for mimetype in ${!mime_icons[@]} ; do
            target="mimetypes/libreoffice-oasis-${mimetype}"
            backup_list+=("$themedir/scalable/${target}.svg")
            for dim in ${blackwhite_sizes[@]} ; do
                backup_list+=("$themedir/${dim}x${dim}/${target}.png")
            done
        done

    done

   for theme in ${color_themes[@]} ; do
        themedir="/usr/share/icons/$theme"
        for app in ${!app_icons[@]} ; do
            target="apps/libreoffice-${app}"
            backup_list+=("$themedir/scalable/${target}.svg")
            for dim in ${color_sizes[@]} ; do
                backup_list+=("$themedir/${dim}x${dim}/${target}.png")
            done
        done
        for mimetype in ${!mime_icons[@]} ; do
            target="mimetypes/libreoffice-oasis-${mimetype}"
            backup_list+=("$themedir/scalable/${target}.svg")
            for dim in ${color_sizes[@]} ; do
                backup_list+=("$themedir/${dim}x${dim}/${target}.png")
            done
        done
    done

    for zipfile in ${color_zips[@]} ${blackwhite_zips[@]} ; do
        backup_list+=(/usr/lib/libreoffice/share/config/images_${zipfile}.zip)
    done

    existing_files=()
    for f in ${backup_list[@]} ; do
        [ -r "$installdir/$f" ] && existing_files+=($f)
    done

    tar -czf "$archive" -C "$installdir" ${existing_files[@]}
    ret=$?
    echo "Backup saved to $(readlink -f "$archive")"
    return $?
}

function build_splash() {
    echo "Building splash from components $1 + $2"
    left_file="$SCRIPTPATH/left_${1}.png"
    if [ ${splash_crops[$2]} ] ; then
        right_file="$SCRIPTPATH/right_blank.png"
        to_crop="$(find_original color $2)"
        extra_cmd=(\( "$to_crop" -crop ${splash_crops[$2]}
                   -scale x169 \) -gravity NorthEast -composite)
    else
        right_file="$SCRIPTPATH/right_${2}.png"
    fi

    convert "$left_file" "$right_file" +append "${extra_cmd[@]}" "$3"
}

function restore_files() {
    archive="$1"
    if [ ! -e "$archive" ] ; then
        echo "ERROR: backup source doesn't exist!"
        return 1
    fi

    verify_writable "restore target" "$installdir" || return 1

    tar -xzf "$archive" -C "$installdir"
    ret=$?
    [ $ret -eq 0 ] && echo "Backup restored."
    return $ret
}

function verify_exists() {
    if [ ! -e "$2" ] ; then
        echo "${3:-ERROR}: The set $1 ($2) doesn't exist!"
        return 1
    fi
}

function verify_writable() {
    verify_exists "$@" || return $?
    if [ ! -w "$2" ] ; then
        echo "${3:-ERROR}: The set $1 ($2) isn't writable!"
        return 1
    fi
}

function verify_tmpdir() {
    if [ ! -d "$2" ] && ! mkdir -p "$2"; then
        echo "${3:-ERROR}: The set $1 ($2) isn't writable or creatable!"
        return 1
    fi

    verify_writable "$@" || return 1
}
