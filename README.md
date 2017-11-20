# LibbieOffice

![LibbieOffice splash](/intro.png)

My attempt at a LibreOffice image replacement script.

The script generates the final result using imagemagick from the original art.
It also supports backup and restore of existing LO resources, mixing and
matching of splash image parts, and is easily extended to add more themes to
the replacement list.

There is also a PKGBUILD for Arch users to easily manage their libbieoffice
installation. It simply fetches the libreoffice-fresh package, replaces its
contents, and repacks it for installation. I hope to add package mod scripts
for more distros in the future.

## Usage
Clone the repo or download the zip, then run `sudo ./libbieoffice_mod.sh` to
peform the replacement with default settings.

To just generate a splash image, use the `build_splash.sh` script, which has
similar options to the mod script.

There is also the `get_trims.sh` script, which doesn't take options, but
fetches and trims the text from all of the art and places it in
`$PWD/trimmed`. Not all of them have crop squares defined; for now, it's
just the main apps and blank.

### Main script
```
Usage: libbieoffice_mod.sh [-hfl] [-o INSTALL_TO] [-a ART_DIR] [-t TMPDIR] [-b BACKUP_DEST] [-r ARCHIVE] [-L LEFT] [-R RIGHT]

Options:
 -o : Specify the installation root. Defaults to /
 -a : Specify the path to the original art. Defaults to TMPDIR/20170826_tysontan_libbie
      Note that filenames are expected to be in the format:
      20170826_tysontan_libbie_nnn_TYPE_nnn_NAME.png
 -f : Forces the script to regenerate all scaled/cropped images
 -t : Specify the temporary directory for processing images.
      Defaults to /tmp/libbieoffice_mod/
 -b : Back up existing theme files to a specified archive.
 -r : Restore theme files from a specified archive
 -L : Splash left component. Options are: libbie libre
 -R : Splash right component. Options are: front 34view blank 5
 -l : Skip downloading the zip; assumes art folder is correct.
 -h : Displays this help message.
```

### Splash only
```
Usage: build_splash.sh [-h] [-l] [-t TMPDIR] [-a ART_DIR] [-L LEFT] [-R RIGHT]

Options:
 -o : Specify the splash file output. Defaults to ./intro.png
 -a : Specify the path to the original art. Defaults to TMPDIR/20170826_tysontan_libbie
      Note that filenames are expected to be in the format:
      20170826_tysontan_libbie_nnn_TYPE_nnn_NAME.png
 -t : Specify the temporary directory for processing images.
      Defaults to /tmp/libbieoffice_mod/
 -L : Splash left component. Options are: libbie libre
 -R : Splash right component. Options are: front 34view blank 5
 -l : Skip downloading the zip; assumes art folder is correct.
 -h : Displays this help message.
 ```

### Trim script
`./get_trims.sh` takes no arguments. When you run it, the script outputs all
three types of images to folders within `$CWD/trimmed`.

# Pull Requests
Yes.

# Known (potential) issues
#### `drm_intel_gem_bo_context_exec() failed: No space left on device`
This error pops up every time I run `imagemagick` on my laptop, and appears to
be related to segfaulting when the program is run as root and tries to use my
GPU. To prevent this, I set `MAGICK_OCL_DEVICE=OFF`.

# License and Credits
This code is licensed under the GPLv3. For more information, read the
[LICENSE](LICENSE).

Credits for @[redsPL](https://github.com/redsPL) for icon crop references,
@[KarlFish](https://github.com/KarlFish) for the idea of the 34view splash
which I have made the default, and anon for the LibbieOffice splash text mod.

Thanks to the ImageMagick developers for making such an awesome and flexible
tool.

And most of all, thanks to [Tyson Tan](https://twitter.com/tysontanx)
([DeviantArt](https://tysontan.deviantart.com/)) for the cute mascot. I don't
care what the folks over at The Document Foundation or their sorry excuse for
a poll said—Libbie's a winner to me, and that's what this repo is all about.
