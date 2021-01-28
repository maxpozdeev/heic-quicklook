#!/bin/bash

rm -rf local
rm -rf include
mkdir local

PREFIX="${PWD}/local"
#PREFIX_JPEG="${PWD}/libturbojpeg"
FLAGS="-mmacosx-version-min=10.7 -stdlib=libc++"

if [ "$1" == "debug" ]; then
 FLAGS="${FLAGS} -g "
elif  [ "$1" == "release" ]; then
 FLAGS="${FLAGS} -O2"
fi

# libde265
cd libde265
make clean > /dev/null
# --disable-sse ?
./configure --prefix=$PREFIX --disable-shared --enable-static --disable-dec265 --disable-sherlock265 --disable-encoder CXXFLAGS="${FLAGS}" || exit 1
make -j2 || exit 1
make install
cd ..


# libheif
export PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig
cd libheif

make clean > /dev/null
#./configure --prefix=$PREFIX --disable-go CXXFLAGS="${FLAGS} -I${PREFIX_JPEG}/include" LDFLAGS=-L${PREFIX_JPEG}
./configure --prefix=$PREFIX --disable-go --disable-examples CXXFLAGS="${FLAGS}" || exit 1
make -j2 || exit 1
make install
cd ..


cp -L local/lib/libheif.dylib ./
install_name_tool -id @rpath/libheif.dylib libheif.dylib

mkdir include
cp -r local/include/libheif ./include/

#rm -rf local

if [[ "$1" == "release" ]]; then
  dsymutil libheif.dylib -o libheif.dylib.dSYM
  strip -S libheif.dylib
fi
