#!/bin/sh

export ROOTFS=/mnt/nfs_root/ubuntu_11.10_d
export CFLAGS="-I${ROOTFS}/usr/include "
export LDFLAGS="-L${ROOTFS}/usr/lib -Xlinker -rpath-link=${ROOTFS}/usr/lib  -lGAL -lpthread -lm -lX11"
export PKG_CONFIG_PATH=${ROOTFS}/usr/share/pkgconfig
export XORG_CFLAGS="-I${ROOTFS}/usr/include/xorg/ -I${ROOTFS}/usr/include/pixman-1"
test -n "$srcdir" || srcdir=`dirname "$0"`
test -n "$srcdir" || srcdir=.
autoreconf --force --install --verbose "$srcdir"
./configure --host=arm-none-linux-gnueabi --prefix=${ROOTFS}/usr  --disable-static
make
sudo make install
