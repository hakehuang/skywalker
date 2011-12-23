#!/bin/bash

make_libs()
{
  iRC=0
  cd $LIB_DIR
  make clean
  make PLATFORM=${1} CROSS_COMPILE=arm-none-linux-gnueabi- INCLUDE="-I${KERNEL_DIR}/include -I${KERNEL_DIR}/drivers/mxc/security/rng/include -I${KERNEL_DIR}/drivers/mxc/security/sahara2/include" -k || iRC=1
  return $iRC
}


if [ "$1" = "-h"  ] || [ $# != 3 ]; then
echo "mklibs.sh <libs_dir> <platfrom_name> <kernel_dir>"
echo "IMX37_3STACK IMX51 IMX53 IMX6Q"
exit
fi

LIB_DIR=$1
KERNEL_DIR=$3

make_libs $2 
