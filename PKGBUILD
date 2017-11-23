#maintainer Caleb Johnson <me@calebj.io>
pkgname=libbieoffice-fresh
_parentVer=5.4.3
_parentRel=3
pkgver=${_parentVer}.${_parentRel}
pkgrel=1
arch=('x86_64')
license=('LGPL3')
url="http://www.libreoffice.org/"

pkgdesc="LibreOffice branch which contains new features and program enhancements"
makedepends=('imagemagick')
depends=('curl>=7.20.0' 'hunspell>=1.2.8' 'python>=3.6' 'libwpd>=0.9.2' 'libwps'
         'neon>=0.28.6' 'pango' 'nspr' 'libjpeg' 'libxrandr' 'libgl' 'dbus-glib'
         'libxslt' 'redland' 'hyphen' 'lpsolve' 'gcc-libs' 'sh' 'graphite' 'icu' 
         'lcms2' 'poppler>=0.24.0' 'libvisio' 'libetonyek' 'libodfgen' 'libcdr'
         'libmspub' 'harfbuzz-icu' 'glew' 'nss' 'clucene' 'hicolor-icon-theme'
         'desktop-file-utils' 'shared-mime-info' 'glu' 'libpagemaker'
         'libxinerama' 'libabw' 'libmwaw' 'libe-book' 'libcups'
         'liblangtag' 'libexttextcat' 'libfbclient' 'libcmis' 'liborcus'
         'libtommath' 'libzmf' 'libatomic_ops' 'xmlsec')
optdepends=('java-runtime:     adds java support'
            'java-environment: required by extension-wiki-publisher and extension-nlpsolver'
            'pstoedit:         translates PostScript and PDF graphics into other vector formats'
            'libmythes:        for use in thesaurus'
            'beanshell:       interactive java -- good for prototyping/macros'
            'libwpg:           library for importing and converting WordPerfect Graphics format'
            'sane:             for scanner access'
            'unixodbc:         adds ODBC database support'
            'gst-plugins-base-libs: for multimedia content, e.g. in Impress'
            'libpaper:         takes care of papersize'
            'postgresql-libs:  for postgresql-connector'
            'coin-or-mp:	   required by the Calc solver'
            'gtk2:             for GTK2 integration'
            'gtk3:             for GTK3 integration'
            'kdelibs:          for KDE desktop integration')
backup=(etc/libreoffice/sofficerc
        etc/libreoffice/bootstraprc
        etc/libreoffice/psprint.conf
        etc/profile.d/libreoffice-fresh.sh
        etc/profile.d/libreoffice-fresh.csh)
provides=('libreoffice' 'libreoffice-en-US')
conflicts=('libreoffice-still' 'libreoffice-fresh')

source=("https://mirror.pkgbuild.com/extra/os/x86_64/libreoffice-fresh-${_parentVer}-${_parentRel}-x86_64.pkg.tar.xz"
        "20170826_tysontan_libbie.zip::https://www.dropbox.com/s/77r848yux6oof8g/20170826_tysontan_libbie_full.zip?dl=0"
        "libbieoffice_mod.sh"
        "libbieoffice_lib.sh"
        "left_libbie.png"
        "left_libre.png"
        "right_5.png"
        "right_blank.png")
        
sha256sums=('b80b3e931facc5f51d2bf0ec9c90c0b9494baef785160364e30a9bd0901a458c'
            '7fadb2620f60da35a5d1eaf95f03e12676c268433f9f41ae2666ed9a885b6dd9'
            '2aff6e7dcd094e1d70242d07c049dc4309f8705cfea036cf2928f0c5f44e1f24'
            '70285028d4740e1bd8afb11fc1363b1f0350af69430923cc66e45460a31766c6'
            '48a57315bc84aaeb93d8e7dd64e1ec2eae0266c0b67a789450df49e6428fdcf4'
            '755e52dead2fa612f99aa2d109ce45f96fc6dacff1ace2dabb03c896f7a402e0'
            '3886927b5032bccbbe3359ed7e7a520089847c8e0e0d378e2c2923174afb1d33'
            'b58569ec5d1e56a8e61c1c4defaf2e3fc24b11a77db6b5e26f601f470c79cc6c')

prepare() {
    cd ${srcdir}
    ./libbieoffice_mod.sh -l -o "${srcdir}" -t "${srcdir}/libbieoffice_tmp" \
                          -a "${srcdir}/20170826_tysontan_libbie/"
}

package() {
    cd ${srcdir}
    cp -a etc usr ${pkgdir}/
}
