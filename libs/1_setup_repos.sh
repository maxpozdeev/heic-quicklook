#!/bin/bash

# With homebrew we need: autoconf automake libtool
# for dav1d we need: meson ninja nasm

# libde265
git clone --depth 1 --branch v1.0.8 https://github.com/strukturag/libde265.git libde265
cd libde265
./autogen.sh || exit 1
cd ..

# libheif
git clone --depth 1 --branch v1.10.0 https://github.com/strukturag/libheif.git libheif
cd libheif
./autogen.sh || exit 1
cd ..

# dav1d
git clone --depth 1 --branch 0.8.1 https://github.com/videolan/dav1d.git libdav1d
