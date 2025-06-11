#!/bin/bash

rm -rf local
rm -rf include
rm -rf static
mkdir local

PREFIX="${PWD}/local"
export MACOSX_DEPLOYMENT_TARGET=10.7
#CORESCOUNT=4
CORESCOUNT=`sysctl -n hw.perflevel0.logicalcpu` || exit 1

if [ -z "$Archs" ]; then
  if [ "$(arch)" = "i386" ]; then
    echo "# If you need to compile for arm64, run as: Archs='x86_64 arm64' $0"
    Archs="x86_64"
  else
    Archs="x86_64 arm64"
  fi
fi
echo "# Build archs: $Archs"

CONFIGURATION="RelWithDebInfo"
if [ "$1" == "debug" ]; then
# FLAGS="${FLAGS} -g "
 CONFIGURATION="Debug"
elif  [ "$1" == "release" ]; then
# FLAGS="${FLAGS} -O3"
 CONFIGURATION="Release"
fi

Build_All() {

  Arch="$1"
  PREFIX_ARCH="$PREFIX/$Arch"
  export PKG_CONFIG_PATH=${PREFIX_ARCH}/lib/pkgconfig
  export CMAKE_PREFIX_PATH="${PREFIX_ARCH}"
  echo "== Building for $Arch architecture =="

  # libjpeg-turbo
  cd libtj
  rm -rf build
  mkdir build && cd build
  cmake ../ -DCMAKE_INSTALL_PREFIX="${PREFIX_ARCH}" -DBUILD_SHARED_LIBS=OFF \
    -DCMAKE_CXX_FLAGS="-stdlib=libc++" \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=${MACOSX_DEPLOYMENT_TARGET} \
    -DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_ARCHITECTURES="$Arch" \
    -DENABLE_STATIC=1 -DENABLE_SHARED=0 -DWITH_JAVA=0 -DWITH_ARITH_ENC=0 -DWITH_JPEG8=1
  make -j$CORESCOUNT || exit 1
  make install
  cd ../..

  # libde265
  cd libde265
  rm -rf build
  mkdir build
  cd build
  cmake ../ -DCMAKE_INSTALL_PREFIX="${PREFIX_ARCH}" -DBUILD_SHARED_LIBS=OFF \
    -DCMAKE_CXX_FLAGS="-stdlib=libc++" \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=${MACOSX_DEPLOYMENT_TARGET} \
    -DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_ARCHITECTURES="$Arch" \
    -DENABLE_SDL=OFF -DENABLE_ENCODER=OFF -DENABLE_DECODER=OFF
  make -j$CORESCOUNT || exit 1
  make install
  cd ../..


  # # dav1d
  # cd libdav1d
  # rm -rf build
  # mkdir build
  # cd build
  # # dav1d by default uses --buildtype=release
  # meson setup --prefix="$PREFIX_ARCH" --default-library=static -Denable_tools=false -Denable_tests=false  .. || exit 1
  # ninja
  # ninja install || exit 1
  # cd ../..


  #aom
  cd aom
  rm -rf build.lib
  mkdir build.lib
  cd build.lib
  cmake .. -DCMAKE_INSTALL_PREFIX="${PREFIX_ARCH}" -DBUILD_SHARED_LIBS=OFF \
    -DCMAKE_CXX_FLAGS="-stdlib=libc++" \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=${MACOSX_DEPLOYMENT_TARGET} \
    -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=../build/cmake/toolchains/${Arch}-macos.cmake \
    -DCONFIG_AV1_ENCODER=0 -DENABLE_DOCS=0 -DENABLE_EXAMPLES=0 -DENABLE_TESTDATA=0 -DENABLE_TESTS=0 -DENABLE_TOOLS=0 || exit 1
  make -j$CORESCOUNT || exit 1
  make install
  cd ../..


  # libheif
  cd libheif
  rm -rf build
  mkdir build
  cd build
  cmake ../ -LA -DCMAKE_INSTALL_PREFIX="${PREFIX_ARCH}" -DBUILD_SHARED_LIBS=OFF \
    -DCMAKE_CXX_FLAGS="-stdlib=libc++" \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=${MACOSX_DEPLOYMENT_TARGET} \
    -DCMAKE_BUILD_TYPE=$CONFIGURATION -DCMAKE_OSX_ARCHITECTURES="$Arch" \
    -DENABLE_PLUGIN_LOADING=OFF -DWITH_REDUCED_VISIBILITY=OFF \
    -DWITH_LIBDE265=ON -DWITH_X265=OFF \
    -DWITH_DAV1D=OFF -DWITH_AOM_DECODER=ON -DWITH_AOM_ENCODER=OFF \
    -DWITH_RAV1E=OFF -DWITH_SvtEnc=OFF \
    -DWITH_JPEG_ENCODER=OFF -DWITH_JPEG_DECODER=OFF -DWITH_OpenJPEG_ENCODER=OFF -DWITH_OpenJPEG_DECODER=OFF \
    -DWITH_OpenH264_ENCODER=OFF -DWITH_OpenH264_DECODER=OFF \
    -DWITH_FFMPEG_DECODER=OFF -DWITH_UNCOMPRESSED_CODEC=OFF \
    -DWITH_LIBSHARPYUV=OFF \
    -DWITH_GDK_PIXBUF=OFF -DWITH_EXAMPLES=OFF -DBUILD_TESTING=OFF
  make -j$CORESCOUNT || exit 1
  make install
  cd ../..

}

for Arch in $Archs;
do
  Build_All $Arch

  LipoArchs="$LipoArchs,$Arch"
  # we assume all header files are the same for both archs
  rm -rf include
  mkdir include
  cp -r local/$Arch/include/libheif ./include/
  cp local/$Arch/include/*.h ./include/

done


# Copy static libs and make universal
mkdir static
for Lib in libde265.a libturbojpeg.a libjpeg.a libheif.a libaom.a;
do
  LipoSrc=""
  for Arch in $Archs;  do  LipoSrc="$LipoSrc local/$Arch/lib/$Lib";  done
  lipo -create $LipoSrc -output static/$Lib
done
