#!/bin/bash

rm -rf local
rm -rf include
mkdir local

PREFIX="${PWD}/local"
FLAGS="-mmacosx-version-min=10.7 -stdlib=libc++"

# libde265
cd libde265
make clean > /dev/null
# --disable-sse ?
./configure --prefix=$PREFIX --disable-shared --enable-static --disable-dec265 --disable-sherlock265 --disable-encoder CXXFLAGS="${FLAGS}"
make
make install
cd ..


# libheif
export PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig
cd libheif

make clean > /dev/null
./configure --prefix=$PREFIX --disable-go CXXFLAGS="${FLAGS}"
make
make install
cd ..


cp -L local/lib/libheif.dylib ./
install_name_tool -id @rpath/libheif.dylib libheif.dylib

mkdir include
cp -r local/include/libheif ./include/

#rm -rf local
