#!/bin/sh -x
KER_VER=2.6.35

echo "./get_weekly.sh //10.192.224.48/LinuxReleaseCandidate/L2.6.31_10.04.01_ER_RC1/Image 10.04.01_ER"

if [ $# -lt 2 ]
then
 echo "need give version like 10.04.00_ER"
 exit 1
fi

if [ $3 ]; then
KER_VER=$3
fi

yes=0

if [ $yes == "1"  ]; then
export PLATFORM=MX233
./newrc_v2 $1/L${KER_VER}_$2_images_${PLATFORM}.tar.gz  || exit 1
export PLATFORM=MX25
echo $passwd | ./newrc_v2 $1/L${KER_VER}_$2_images_${PLATFORM}.tar.gz || exit 1
export PLATFORM=MX28
echo $passwd | ./newrc_v2 $1/L${KER_VER}_$2_images_${PLATFORM}.tar.gz || exit 1
export PLATFORM=MX31
echo $passwd | ./newrc_v2 $1/L${KER_VER}_$2_images_${PLATFORM}.tar.gz || exit 1
export PLATFORM=MX35
echo $passwd | ./newrc_v2 $1/L${KER_VER}_$2_images_${PLATFORM}.tar.gz || exit 1
##export PLATFORM=MX37
##echo $passwd | ./newrc_v2 $1/L${KER_VER}_$2_images_${PLATFORM}.tar.gz || exit 1
export PLATFORM=MX51
echo $passwd | ./newrc_v2 $1/L${KER_VER}_$2_images_MX5X.tar.gz || exit 1
export PLATFORM=MX50
echo $passwd | ./newrc_v2 $1/L${KER_VER}_$2_images_MX5X.tar.gz || exit 1
export PLATFORM=MX53
echo $passwd | ./newrc_v2 $1/L${KER_VER}_$2_images_MX5X.tar.gz || exit 1
export PLATFORM=MX63
./newrc_v2 $1 $2 || exit 1
export PLATFORM=MX61
./newrc_v2 $1 $2 || exit 1
fi
export PLATFORM=MX60
./newrc_v2 $1 $2 || exit 1
