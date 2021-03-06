#!/bin/bash -x

#PLATFORM="233 25 28 31 35 37 25 50 51 53"
#PLATFORM="IMX50RDP IMX50-RDP3 IMX53LOCO IMX51-BABBAGE IMX53SMD \
#IMX6-SABREAUTO IMX6-SABRELITE IMX6ARM2 IMX6Q-Sabre-SD IMX6DL-ARM2 \
#IMX6DL-Sabre-SD IMX6Solo-SABREAUTO \
#IMX6Sololite-ARM2 IMX6SL-EVK"
PLATFORM="IMX6SL-EVK"
BUILD=n
#kernel branch and vte branch need define all one branch
KERNEL_BRH=imx_2.6.35
#KERNEL_BRH=imx_2.6.38
VTE_BRH=imx2.6.35.3
UBOOT_BRH=imx_v2009.08
#PLATFORM="5x"
#VTE_TARGET_PRE=/mnt/vte/
VTE_TARGET_PRE2=/rootfs/wb/
#VTE_TARGET_PRE3=/mnt/nfs_rd/
TARGET_ROOTFS=/rootfs/nfs_root/
#TARGET_ROOTFS_RD=/mnt/nfs_root_rd/
ROOTDIR=/home/ubuntu/release_build/
KERNEL_DIR=${ROOTDIR}/linux-2.6-imx/
UBOOT_DIR=${ROOTDIR}/uboot-imx
VTE_DIR=${ROOTDIR}/vte
TOOLSDIR=${ROOTDIR}/skywalker/udp_sync
UCONFDIR=${ROOTDIR}/skywalker/uboot-env
SCRPTSDIR=${ROOTDIR}/skywalker/vte_script

all_one_branch=n

TOOL_CHAIN=/opt/freescale/usr/local/gcc-4.6.2-glibc-2.13-linaro-multilib-2011.12/fsl-linaro-toolchain/bin/
export PATH=$PATH:/opt/freescale/usr/local/gcc-4.6.2-glibc-2.13-linaro-multilib-2011.12/fsl-linaro-toolchain/bin/

RC=0

#below is the matrix for rootfs
declare -a kernel_branch;
declare -a vte_branch;
declare -a plat_name;
declare -a soc_name;
declare -a kernel_configs;
declare -a vte_configs;
declare -a rootfs_apd;
declare -a rootfs;
declare -a target_configs;
declare -a vte_target_configs;
declare -a xrootfs;
declare -a test_plan;
# As bash only support 1 dimension array below sequence is our assumption
# 0   1  2  3  4  5  6  7  8  9  10 11
#(23 25 28 31 35 37 50 50  51 53 53 61)
#SOC names
#           0     1    2    3    4   5    6    7    8   9 10
SOC_CNT=20
vte_branch=("imx2.6.35.3" "imx2.6.35.3" "imx2.6.35.3" "imx2.6.35.3" "imx2.6.35.3" "imx2.6.35.3" \
"imx2.6.35.3" "imx2.6.35.3" "imx2.6.35.3" "imx2.6.35.3" "imx2.6.35.3" "master" "master" "master" \
"master" "master" "master" "master" "master" "master");
plat_name=("IMX23EVK" "IMX25-3STACK" "IMX28EVK" "IMX31-3STACK" "IMX35-3STACK" \
"IMX37-3STACK" "IMX50RDP" "IMX50-RDP3"  "IMX51-BABBAGE" "IMX53SMD" "IMX53LOCO" \
"IMX6-SABREAUTO" "IMX6-SABRELITE" "IMX6ARM2" "IMX6Q-Sabre-SD" "IMX6DL-ARM2" \
"IMX6DL-Sabre-SD"  "IMX6Solo-SABREAUTO" "IMX6Sololite-ARM2" "IMX6SL-EVK");
test_plan=("_" "_" "_" "_" "_" "_" "_" "_" "_" "_" "_" "_AI_" "_lite_" \
"_ARM2_" "_SMD_" "_ARM2_" "_SMD_" "_AI_" "_ARM2_" "_EVK_");
soc_name=("233" "25" "28" "31" "35" "37" "50"  "50" "51" "53" "53" "63" "63" \
"63" "63" "61" "61" "61" "60" "60");
#default u-boot kernel configs for each platform
#default kernel configs for each platform
kernel_configs=("imx23evk_defconfig" "imx25_3stack_defconfig" \
"imx28evk_defconfig" "mx3_defconfig" "mx35_3stack_config" "mx3_defconfig" \
"imx5_defconfig" "imx5_defconfig" "imx5_defconfig" "imx5_defconfig" "imx5_defconfig" \
"imx6_defconfig" "imx6_defconfig" "imx6_defconfig" "imx6_defconfig" "imx6_defconfig" \
"imx6_defconfig" "imx6_defconfig" "imx6s_defconfig" "imx6s_defconfig");
#vte configs
vte_configs=("mx233_armadillo_config" "mx25_3stack_config" "mx28_evk_config" \
"mx31_3stack_config" "mx35_3stack_config" "mx37_3stack_config" \
"imx51" "imx51" "imx51" "imx51" \
"imx51" "imx6q" "imx6q" "imx6q" \
"imx6q" "imx6q" "imx6q" "imx6q" "imx6q" "imx6q");
#rootfs and vte apendix
rootfs_apd=("" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "");
xrootfs=("" "" "" "" "" "" "" "" "" "" "" "ubuntu_11.10_d" "ubuntu_11.10_d" "ubuntu_11.10_d" "ubuntu_11.10_d" "ubuntu_11.10_d" "ubuntu_11.10_d" "ubuntu_11.10_d" "ubuntu_11.10_sd" "ubuntu_11.10_sd")
target_configs=("0" "0" "0" "0" "0" "0" "0" "0" "0" "0" "0" "0" "0" "0" "0" "0" "0" "0" "0" "0");
vte_target_configs=("0" "0" "0" "0" "0" "0" "0" "0" "0" "0" "0" "0" "0" "0" "0" "0" "0" "0" "0" "0");

make_kernel()
{
echo "make Platform $2 with $1"
cd $KERNEL_DIR
if [ "$old_kernel_config" = $1 ];then
if [ "$old_kernel_rc" -eq 0 ]; then
  if [ "$old_kernel_target" = "${2}${3}"  ]; then
	return $old_kernel_rc
  fi
fi
return $old_kernel_rc
fi
old_kernel_config=$1
old_kernel_target=${2}${3}
make distclean
make ARCH=arm CROSS_COMPILE=${TOOL_CHAIN}arm-none-linux-gnueabi- $1 || return 1
make ARCH=arm CROSS_COMPILE=${TOOL_CHAIN}arm-none-linux-gnueabi- -j 4 uImage|| return 2
#KERNEL_VER=$(./scripts/setlocalversion)
#sudo rm -rf ${TARGET_ROOTFS}/imx${2}_rootfs${3}/lib/modules/*-daily*
make ARCH=arm CROSS_COMPILE=${TOOL_CHAIN}arm-none-linux-gnueabi- -j 4 modules|| return 4
old_kernel_rc=0
return 0
}

sync_testcase()
{
 php $ROOTDIR/skywalker/vte_script/client_skywalker_case.php $1 > ${ROOTDIR}/${2}
 lines=$(cat ${ROOTDIR}/$2 | wc -l)
 if [ $lines -gt 1 ]; then
	sudo cp ${ROOTDIR}/${2} ${VTE_TARGET_PRE2}/vte_mx${3}/runtest/  
   return 0
 else
	return 1
 fi
}

make_vte()
{
ret=0
sync_testcase $5 "imx${2}${4}auto" ${2} "${3}" 
cd $VTE_DIR
if [ "$old_vte_config" = $1 ] && [ $old_soc = $2 ]; then
 if [ $old_vte_soc = $2$3  ]; then
  #no need to copy to the same folder again
  return $old_vte_rc
 fi
 if [ $old_vte_rc -eq 0 ] && [ -e $VTE_DIR/install ]; then
   #sudo cp -a install/* ${VTE_TARGET_PRE}/vte_mx${2}_${3}d/
   #sudo cp -a testcases/bin/* ${VTE_TARGET_PRE}/vte_mx${2}_${3}d/testcases/bin/
   #sudo cp mytest ${VTE_TARGET_PRE}/vte_mx${2}_${3}d/
   sudo cp -a install/* ${VTE_TARGET_PRE2}/vte_mx${2}/
   sudo cp -a testcases/bin/* ${VTE_TARGET_PRE2}/vte_mx${2}/testcases/bin/
   sudo cp mytest ${VTE_TARGET_PRE2}/vte_mx${2}/
 fi
return $old_vte_rc
fi
old_vte_config=$1
old_vte_soc=$2$3
old_soc=$2
make distclean
make clean
sudo rm -rf install
if [ -e $1 ];then
. $1
fi
export KLINUX_SRCDIR=${TARGET_ROOTFS}/imx${2}_rootfs${3}_r/usr/src/linux/
export KERNEL_SRCDIR=${KERNEL_DIR}
export KLINUX_BLTDIR=${KERNEL_DIR}
export CROSS_COMPILE=${TOOL_CHAIN}arm-none-linux-gnueabi-
export CROSS_COMPILER=${TOOL_CHAIN}arm-none-linux-gnueabi-
export CC=${CROSS_COMPILE}gcc
export CFLAGS="-Wall -O2 -fsigned-char -mcpu=cortex-a9 -mfpu=vfp -mfloat-abi=softfp -DFSL_ARM=1"
export ARCH_CPU=arm
export ARCH_PLATFORM=$1
autoreconf -f -i -Wall,no-obsolete
aclocal -I m4
autoconf
automake -a
make autotools
./configure --host=arm-none-linux-gnueabi --prefix=$(pwd)/install CC=${CROSS_COMPILE}gcc
make
make vte || ret=1
make apps || ret=2
make install
#make ltp tests
#if [ $BUILD = "y" ]; then
#sudo scp -r bin/* b17931@survivor:/rootfs/wb/vte_mx${2}_d/bin
#fi
#sudo cp -a install/* ${VTE_TARGET_PRE}/vte_mx${2}_${3}d/
#sudo cp -a testcases/bin/* ${VTE_TARGET_PRE}/vte_mx${2}_${3}d/testcases/bin/
#sudo cp mytest ${VTE_TARGET_PRE}/vte_mx${2}_${3}d/
sudo cp -a install/* ${VTE_TARGET_PRE2}/vte_mx${2}/
sudo cp -a testcases/bin/* ${VTE_TARGET_PRE2}/vte_mx${2}/testcases/bin/
sudo cp mytest ${VTE_TARGET_PRE2}/vte_mx${2}/
if [ $deploy_vte_target_rd -eq 1 ]; then
sudo cp -a install/* ${VTE_TARGET_PRE3}/vte_mx${2}/
sudo cp -a testcases/bin/* ${VTE_TARGET_PRE3}/vte_mx${2}/testcases/bin/
sudo cp mytest ${VTE_TARGET_PRE3}/vte_mx${2}/
fi
#sudo scp -r testcases/bin/* b17931@survivor:/rootfs/wb/vte_mx${2}_d/testcases/bin
old_vte_rc=0
return $ret
}

make_tools()
{
 cd $TOOLSDIR
 CROSS_COMPILER="" make || return 7
 cd $UCONFDIR
 make CC=gcc || return 8
}

branch_vte()
{
if [ $all_one_branch = "n" ]; then
 if [ "$old_vte_branch" = $1 ];then
	return 0
 fi
 old_vte_branch=$1
 old_vte_config=""
 cd $ROOTDIR
 if [ ! -e ${VTE_DIR} ]; then
 git clone git://shlx12.ap.freescale.net/vte
 fi
 cd $VTE_DIR
 git add . 
 git commit -s -m"reset"
 git reset --hard HEAD~1
 git checkout -b temp origin/$1 || git checkout temp
 git branch -D build
 git fetch origin +$1:build && git checkout build || return 1
fi
 return 0
}

#main

old_kernel_config=
old_kernel_rc=0
old_vte_config=
old_vte_rc=0
old_vte_branch=""
old_kernel_branch=""
KERNEL_VER=
old_ut_rc=0
old_ut_plat=0
old_lib_platfm=0

 cd $ROOTDIR
 if [ ! -e $ROOTDIR/skywalker ]; then
  git clone git://10.192.225.222/skywalker
  fi
  cd $ROOTDIR/skywalker
  git add . 
  git commit -s -m"reset"
  git reset --hard HEAD~1
  git checkout -b temp || git checkout temp
  git branch -D build
  git fetch origin +master:build && git checkout build || exit -4


for i in $PLATFORM;
do
  j=0
  while [ $j -lt $SOC_CNT ];do
   c_plat=${plat_name[${j}]}
   deploy_target_rd=0
   deploy_vte_target_rd=0
   if [ "$c_plat" = $i ];then
     deploy_target_rd=${target_configs[${j}]}
     deploy_vte_target_rd=${vte_target_configs[${j}]}
     c_soc=${soc_name[${j}]}
     make_kernel ${kernel_configs[${j}]} $c_soc "${rootfs_apd[${j}]}" ${xrootfs[${j}]} || old_kernel_rc=$?
     if [ $old_kernel_rc -ne 0 ]; then 
	RC=$(echo $RC $i)
     fi
     branch_vte ${vte_branch[$j]}
     make_vte  ${vte_configs[${j}]} $c_soc "${rootfs_apd[${j}]}" ${test_plan[${j}]} $c_plat || old_vte_rc=$?
   fi
   j=$(expr $j + 1)
  done
done


echo $RC
if [ "$RC" = "0" ]; then
echo "VTE daily build with $RC" | mutt -s "VTE new tool chain daily build OK" \
b20222@freescale.com 
echo build success!!
else
echo "VTE daily build with $RC" | mutt -s "VTE new tool chain daily build Fail" \
b20222@freescale.com
echo build Fail $RC!
fi

