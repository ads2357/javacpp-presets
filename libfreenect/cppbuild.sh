#!/bin/bash
# This file is meant to be included by the parent cppbuild.sh script
if [[ -z "$PLATFORM" ]]; then
    pushd ..
    bash cppbuild.sh "$@" libfreenect
    popd
    exit
fi

LIBFREENECT_VERSION=0.5.2
download https://github.com/OpenKinect/libfreenect/archive/v$LIBFREENECT_VERSION.zip libfreenect-$LIBFREENECT_VERSION.zip

mkdir -p $PLATFORM
cd $PLATFORM
mkdir -p include lib bin
unzip -o ../libfreenect-$LIBFREENECT_VERSION.zip

if [[ $PLATFORM == windows* ]]; then
    download http://downloads.sourceforge.net/project/libusb-win32/libusb-win32-releases/1.2.6.0/libusb-win32-bin-1.2.6.0.zip libusb-win32-bin-1.2.6.0.zip
    download ftp://sourceware.org/pub/pthreads-win32/pthreads-w32-2-9-1-release.zip pthreads-w32-2-9-1-release.zip

    unzip -o libusb-win32-bin-1.2.6.0.zip
    unzip -o pthreads-w32-2-9-1-release.zip -d pthreads-w32-2-9-1-release/
    patch -Np1 -d libfreenect-$LIBFREENECT_VERSION < ../../libfreenect-$LIBFREENECT_VERSION-windows.patch
fi

cd libfreenect-$LIBFREENECT_VERSION

case $PLATFORM in
    linux-x86)
        CC="gcc -m32" CXX="g++ -m32" $CMAKE -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=..
        make -j4
        make install
        ;;
    linux-x86_64)
        CC="gcc -m64" CXX="g++ -m64" $CMAKE -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=..
        make -j4
        make install
        ;;
    macosx-*)
        patch -Np1 < ../../../libfreenect-$LIBFREENECT_VERSION-macosx.patch
        $CMAKE -DCMAKE_BUILD_TYPE=Release -DBUILD_EXAMPLES=OFF -DBUILD_FAKENECT=OFF -DCMAKE_INSTALL_PREFIX=..
        make -j4
        make install
        ;;
    windows-x86)
        $CMAKE -DCMAKE_BUILD_TYPE=Release -DLIBUSB_1_INCLUDE_DIR="../libusb-win32-bin-1.2.6.0/include" -DLIBUSB_1_LIBRARY="../libusb-win32-bin-1.2.6.0/lib/msvc/libusb.lib" -DTHREADS_PTHREADS_INCLUDE_DIR="../pthreads-w32-2-9-1-release/Pre-built.2/include" -DTHREADS_PTHREADS_WIN32_LIBRARY="../pthreads-w32-2-9-1-release/Pre-built.2/lib/x86/pthreadVC2.lib" -DBUILD_EXAMPLES=OFF -DBUILD_FAKENECT=OFF -DCMAKE_INSTALL_PREFIX=..
        nmake
        nmake install
        cp -r ../libusb-win32-bin-1.2.6.0/lib/msvc/* ../lib
        cp -r ../libusb-win32-bin-1.2.6.0/bin/x86/* ../bin
        cp -r ../pthreads-w32-2-9-1-release/Pre-built.2/lib/x86/* ../lib
        cp -r ../pthreads-w32-2-9-1-release/Pre-built.2/dll/x86/* ../bin
        ;;
    windows-x86_64)
        $CMAKE -DCMAKE_BUILD_TYPE=Release -DLIBUSB_1_INCLUDE_DIR="../libusb-win32-bin-1.2.6.0/include" -DLIBUSB_1_LIBRARY="../libusb-win32-bin-1.2.6.0/lib/msvc_x64/libusb.lib" -DTHREADS_PTHREADS_INCLUDE_DIR="../pthreads-w32-2-9-1-release/Pre-built.2/include" -DTHREADS_PTHREADS_WIN32_LIBRARY="../pthreads-w32-2-9-1-release/Pre-built.2/lib/x64/pthreadVC2.lib" -DBUILD_EXAMPLES=OFF -DBUILD_FAKENECT=OFF -DCMAKE_INSTALL_PREFIX=..
        nmake
        nmake install
        cp -r ../libusb-win32-bin-1.2.6.0/lib/msvc_x64/* ../lib
        cp -r ../libusb-win32-bin-1.2.6.0/bin/amd64/* ../bin
        cp -r ../pthreads-w32-2-9-1-release/Pre-built.2/lib/x64/* ../lib
        cp -r ../pthreads-w32-2-9-1-release/Pre-built.2/dll/x64/* ../bin
        ;;
    *)
        echo "Error: Platform \"$PLATFORM\" is not supported"
        ;;
esac

cd ../..
