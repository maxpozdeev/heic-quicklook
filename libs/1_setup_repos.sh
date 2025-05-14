#!/bin/bash

# With homebrew we need: pkg-config autoconf automake libtool
# for dav1d we need: meson ninja nasm

# libde265
git clone --depth 1 --branch v1.0.16 https://github.com/strukturag/libde265.git libde265 || exit 1
cd libde265
./autogen.sh || exit 1
cd ..

# libheif
git clone --depth 1 --branch v1.17.6 https://github.com/strukturag/libheif.git libheif || exit 1
cd libheif
#./autogen.sh || exit 1
cd ..

# dav1d
git clone --depth 1 --branch 1.5.1 https://github.com/videolan/dav1d.git libdav1d || exit 1
