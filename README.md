# Scilab binary as an AppImage

[![Build Status](https://travis-ci.org/davidcl/Scilab.AppDir.svg?branch=master)](https://travis-ci.org/davidcl/Scilab.AppDir)

This project aims to ship the Scilab binary from [www.scilab.org](https://www.scilab.org) as an [AppImage](https://appimage.org) for standalone usage.

The runner script shipped within the scilab tarball is generic enough to be re-used ; all the heavy lifting should be done upstream and shared cross-distro.

## How to reproduce the AppImage binary ?

The `appimage_builder.sh` script is used to fetch appimagestool and Scilab binaries from the web. Use it to create or customize your own Scilab binary.

