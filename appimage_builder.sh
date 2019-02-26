#!/usr/bin/env bash

set -e
set -x

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
        curl -O https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage
        chmod a+x appimagetool-x86_64.AppImage 
    fi

    if [[ ! -f scilab-${VERSION}.bin.linux-${ARCH}.tar.gz ]]; then
        curl -O https://www.scilab.org/download/${VERSION}/scilab-${VERSION}.bin.linux-${ARCH}.tar.gz
    fi
}

function build {
    tar -xzf scilab-${VERSION}.bin.linux-${ARCH}.tar.gz
    rm usr && ln -s scilab-${VERSION} usr

   ./appimagetool-x86_64.AppImage .
}

# default parameters value
BUILD=b
FETCH=f
VERSION=$(curl -v -L https://www.scilab.org/download/latest 2>&1 1>/dev/null \
    |awk '/^> GET /{split($3,a,"/")} END{print a[3]}')
ARCH=$(uname -m)

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


