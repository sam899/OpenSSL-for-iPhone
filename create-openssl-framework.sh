#!/bin/sh

FWNAME=openssl

if [ ! -d lib ]; then
    echo "Please run build-libssl.sh first!"
    exit 1
fi

if [ -d $FWNAME.framework ]; then
    echo "Removing previous $FWNAME.framework copy"
    rm -rf $FWNAME.framework
fi

echo "Creating $FWNAME.framework"
mkdir -p $FWNAME.framework/Headers

if [ "$1" == "dynamic" ]; then
    LIBTOOL_FLAGS="-dynamic -undefined dynamic_lookup"
    SDKVERSION=`xcrun -sdk iphoneos --show-sdk-version`
    CURRENTPATH=`pwd`
    for f in ${CURRENTPATH}/bin/iPhoneSimulator${SDKVERSION}-i386.sdk/lib ${CURRENTPATH}/bin/iPhoneSimulator${SDKVERSION}-x86_64.sdk/lib  ${CURRENTPATH}/bin/iPhoneOS${SDKVERSION}-armv7.sdk/lib ${CURRENTPATH}/bin/iPhoneOS${SDKVERSION}-armv7s.sdk/lib ${CURRENTPATH}/bin/iPhoneOS${SDKVERSION}-arm64.sdk/lib; do
        arch=`echo $f | sed 's,^.*-\(.*\)\.sdk.*$,\1,'`
        xcrun ld -arch_multiple -arch $arch -dylib -dynamic -all_load -force_cpusubtype_ALL -no_arch_warnings -dylib_install_name openssl.framework/openssl -undefined dynamic_lookup $f/libcrypto.a $f/libssl.a -o openssl.framework/openssl.libtool.$arch -ios_version_min 9.0 -final_output openssl.framework/openssl
    done
    xcrun lipo -create -output openssl.framework/openssl openssl.framework/openssl.libtool.i386 openssl.framework/openssl.libtool.armv7 openssl.framework/openssl.libtool.armv7s openssl.framework/openssl.libtool.x86_64 openssl.framework/openssl.libtool.arm64 
    for f in ${CURRENTPATH}/bin/iPhoneSimulator${SDKVERSION}-i386.sdk/lib ${CURRENTPATH}/bin/iPhoneSimulator${SDKVERSION}-x86_64.sdk/lib  ${CURRENTPATH}/bin/iPhoneOS${SDKVERSION}-armv7.sdk/lib ${CURRENTPATH}/bin/iPhoneOS${SDKVERSION}-armv7s.sdk/lib ${CURRENTPATH}/bin/iPhoneOS${SDKVERSION}-arm64.sdk/lib; do
        arch=`echo $f | sed 's,^.*-\(.*\)\.sdk.*$,\1,'`
        rm openssl.framework/openssl.libtool.$arch
    done
else
    LIBTOOL_FLAGS="-static"
    libtool -v -no_warning_for_no_symbols $LIBTOOL_FLAGS -o $FWNAME.framework/$FWNAME lib/libcrypto.a lib/libssl.a
fi

cp -r include/$FWNAME/* $FWNAME.framework/Headers/
echo "Created $FWNAME.framework"
