#!/bin/bash

# With homebrew we need: pkg-config autoconf automake libtool
# for dav1d we need: meson ninja nasm

# libde265
git clone --depth 1 --branch v1.0.16 https://github.com/strukturag/libde265.git libde265 || exit 1

# libheif
git clone --depth 1 --branch v1.19.8 https://github.com/strukturag/libheif.git libheif || exit 1

# dav1d
#git clone --depth 1 --branch 1.5.1 https://github.com/videolan/dav1d.git libdav1d || exit 1

# turbo-jpeg
git clone --depth 1 --branch 3.1.0 https://github.com/libjpeg-turbo/libjpeg-turbo.git libtj || exit 1

# aom
git clone --depth 1 --branch v3.12.1 https://aomedia.googlesource.com/aom