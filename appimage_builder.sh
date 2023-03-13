#!/usr/bin/env bash

set -e
set -x
DIRNAME=$(dirname "$0")

function usage {
    echo "Usage: ./appimage_builder.sh"
    echo "-h         : display help"
    echo "-r VERSION : use a specific VERSION, could be version number or \"latest\" (default)"
    echo "-m ARCH    : use a specific ARCH, the machine is detected by default"
    echo "-b         : build only, Scilab binary and appimagetool is present"
    echo "-f         : fetch only, Scilab binary and appimagetool will be downloaded"
}

function fetch {
    if [[ ! -f appimagetool-x86_64.AppImage ]]; then
        curl -LO https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage
        chmod a+x appimagetool-x86_64.AppImage 
    fi

    if [[ ! -f scilab-${VERSION}.bin.linux-${ARCH}.tar.gz ]]; then
        curl -LO https://www.scilab.org/download/${VERSION}/scilab-${VERSION}.bin.${ARCH}.tar.xz
    fi
}

function build {
    tar -xzf scilab-${VERSION}.bin.${ARCH}.tar.xz -C ${DIRNAME}
    rm ${DIRNAME}/usr && ln -s scilab-${VERSION} ${DIRNAME}/usr

    # AppStream upstream metadata
    METAINFO=${DIRNAME}/usr/share/metainfo
    [ -d ${METAINFO} ] || mkdir ${METAINFO}
    mv ${DIRNAME}/usr/share/appdata/scilab.appdata.xml ${METAINFO}/

    ./appimagetool-x86_64.AppImage ${DIRNAME}
}

# default parameters value
BUILD=b
FETCH=f
if [[ -n "$TRAVIS_TAG" ]]; then
    IFS=-
    set $TRAVIS_TAG
    VERSION=$1
    unset IFS
else
    VERSION=$(curl -v -L https://www.scilab.org/download/latest 2>&1 1>/dev/null \
              |awk '/^> GET /{split($3,a,"/")} END{print a[3]}')
fi
# ARCH=$(cc -dumpmachine)
ARCH=$(sh --version | tr -d '()' |awk 'NR==1{print $NF}')

while (( "$#" )); do

    case "$1" in
        "-h")
            usage
            exit 0
            ;;

        "-r")
            shift
            VERSION="$1"
            ;;

        "-m")
            shift
            ARCH="$1"
            ;;

        "-b")
            FETCH=
            ;;

        "-f")
            BUILD=
            ;;
    esac

    shift
done

# action
if [[ -n $FETCH ]]; then
    fetch
fi
if [[ -n $BUILD ]]; then
    build
fi

