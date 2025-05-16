#!/bin/bash

rm -rf local
rm -rf include
#rm -f libheif.dylib
#rm -rf libheif.dylib.dSYM
rm -rf static
mkdir local

PREFIX="${PWD}/local"
#PREFIX_JPEG="${PWD}/libturbojpeg"
FLAGS="-mmacosx-version-min=10.7 -stdlib=libc++"
export MACOSX_DEPLOYMENT_TARGET=10.7
export PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig
# libheif links libjpeg and libpng with examples only
#export PKG_CONFIG_LIBDIR=$PREFIX/lib/pkgconfig
CORESCOUNT=4

CONFIGURATION="RelWithDebInfo"
if [ "$1" == "debug" ]; then
 FLAGS="${FLAGS} -g "
 CONFIGURATION="Debug"
elif  [ "$1" == "release" ]; then
 FLAGS="${FLAGS} -O3"
 CONFIGURATION="Release"
fi

# libde265
cd libde265
make clean > /dev/null
# --disable-sse ?
./configure --prefix="$PREFIX" --disable-shared --enable-static --disable-dec265 --disable-sherlock265 --disable-encoder CXXFLAGS="${FLAGS}" || exit 1
make -j$CORESCOUNT || exit 1
make install
cd ..

# dav1d
cd libdav1d

rm -rf build
mkdir build
cd build
# dav1d by default uses --buildtype=release
meson --prefix="$PREFIX" --default-library=static  .. || exit 1
ninja install || exit 1
cd ../..


# libheif
cd libheif

rm -rf build
mkdir build
cd build
cmake ../ -LA -DCMAKE_INSTALL_PREFIX="${PREFIX}" -DBUILD_SHARED_LIBS=OFF \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=${MACOSX_DEPLOYMENT_TARGET} \
  -DCMAKE_BUILD_TYPE=$CONFIGURATION \
  -DENABLE_PLUGIN_LOADING=OFF -DWITH_REDUCED_VISIBILITY=OFF \
  -DWITH_LIBDE265=ON -DWITH_X265=OFF \
  -DWITH_DAV1D=ON -DWITH_AOM_DECODER=OFF -DWITH_AOM_ENCODER=OFF \
  -DWITH_RAV1E=OFF -DWITH_SvtEnc=OFF \
  -DWITH_JPEG_ENCODER=OFF -DWITH_JPEG_DECODER=OFF -DWITH_OpenJPEG_ENCODER=OFF -DWITH_OpenJPEG_DECODER=OFF \
  -DWITH_OpenH264_ENCODER=OFF -DWITH_OpenH264_DECODER=OFF \
  -DWITH_FFMPEG_DECODER=OFF -DWITH_UNCOMPRESSED_CODEC=OFF \
  -DWITH_LIBSHARPYUV=OFF \
  -DWITH_GDK_PIXBUF=OFF -DWITH_EXAMPLES=OFF -DBUILD_TESTING=OFF
make -j$CORESCOUNT
make install
cd ../..


#cp -L local/lib/libheif.dylib ./
#install_name_tool -id @rpath/libheif.dylib libheif.dylib

mkdir include
cp -r local/include/libheif ./include/

mkdir static
cp local/lib/libde265.a static/
cp local/lib/libdav1d.a static/
cp local/lib/libheif.a static/


#rm -rf local

#if [[ "$1" == "release" ]]; then
#  dsymutil libheif.dylib -o libheif.dylib.dSYM
#  strip -S libheif.dylib
#fi
