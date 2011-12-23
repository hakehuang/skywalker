#!/bin/bash

make_unit_test()
{
 cd $UNITTEST_DIR
 old_ut_rc=0
 PLATFORM=$1
 KERNELDIR=$KERNEL_DIR
 KBUILD_OUTPUT=$KERNEL_DIR
 INCLUDE="-I${TARGET_ROOTFS}/usr/include \
 -I${TARGET_ROOTFS}/usr/src/linux/include \
 -I./include/"
 LIB="-L${TARGET_ROOTFS}/usr/lib"
 make distclean
 make -C module_test KBUILD_OUTPUT=$KBUILD_OUTPUT LINUXPATH=$KERNELDIR  CC=arm-none-linux-gnueabi-gcc \
 CROSS_COMPILE=arm-none-linux-gnueabi- || old_ut_rc=1
 make -j1 PLATFORM=$PLATFORM INC="${INCLUDE}" LIBS=${LIB} test  CC=arm-none-linux-gnueabi-gcc \
 CROSS_COMPILE=arm-none-linux-gnueabi- || old_ut_rc=$(expr $old_ut_rc + 2)
 #sudo make -C module_test -j1 LINUXPATH=$KERNELDIR KBUILD_OUTPUT=$KBUILD_OUTPUT \
 #CROSS_COMPILE=arm-none-linux-gnueabi- \
 #DEPMOD=/bin/true INSTALL_MOD_PATH=${TARGET_ROOTFS}/imx${2}_rootfs install -k || old_ut_rc=$(expr $old_ut_rc + 4)
 #sudo  make PLATFORM=$PLATFORM DESTDIR=${TARGET_ROOTFS}/imx${2}_rootfs/unit_tests \
 #CROSS_COMPILE=arm-none-linux-gnueabi- install || old_ut_rc=$(expr $old_ut_rc + 8)
 #return $old_ut_rc
}


if [ "$1" = "-h"  ] || [ $# != 4 ]; then
echo "mkunit.sh <unit_test_dir> <platfrom_name> <kernel_dir> <Target_rootfs>"
echo "platfrom_name available: IMX233 IMX25 IMX28 IMX3 IMX5 IMX51 IMX53 IMX6"
exit
fi

UNITTEST_DIR=$1
KBUILD_OUTPUT=$3
KERNELDIR=$3
TARGET_ROOTFS=$4

make_unit_test $2  
