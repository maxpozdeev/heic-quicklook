#!/bin/bash

# With homebrew we need: autoconf automake libtool

# libde265
git clone https://github.com/strukturag/libde265.git libde265
cd libde265
./autogen.sh || exit 1
cd ..

# libheif
git clone https://github.com/strukturag/libheif.git libheif
cd libheif
./autogen.sh || exit 1
cd ..

