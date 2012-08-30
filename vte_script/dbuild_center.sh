#!/bin/bash -x

#PLATFORM="IMX6SL-EVK"
PLATFORM="IMX50RDP IMX50-RDP3 IMX53LOCO IMX51-BABBAGE IMX53SMD IMX6-SABREAUTO \
IMX6-SABRELITE IMX6ARM2 IMX6Q-Sabre-SD IMX6DL-ARM2 IMX6DL-Sabre-SD IMX6Solo-SABREAUTO \
IMX6Sololite-ARM2 IMX6SL-EVK"
BUILD=y
#kernel branch and vte branch need define all one branch
KERNEL_BRH=imx_2.6.35
#KERNEL_BRH=imx_2.6.38
VTE_BRH=imx2.6.35.3
UBOOT_BRH=imx_v2009.08

CENTER_SERVER=10.192.244.6
VTE_TARGET_PRE2=/rootfs/wb
TARGET_ROOTFS=/rootfs/
ROOTDIR=/home/ubuntu/daily_build/
KERNEL_DIR=${ROOTDIR}/linux-2.6-imx/
UBOOT_DIR=${ROOTDIR}/uboot-imx
VTE_DIR=${ROOTDIR}/vte
TOOLSDIR=${ROOTDIR}/skywalker/udp_sync
UCONFDIR=${ROOTDIR}/skywalker/uboot-env
SCRPTSDIR=${ROOTDIR}/skywalker/vte_script
UNITTEST_DIR=${ROOTDIR}/linux-test
FIRMWARE_DIR=${ROOTDIR}/linux-firmware-imx
LIB_DIR=${ROOTDIR}/linux-lib
GPU_DIR=${ROOTDIR}/gpu-viv
EXA_DIR=${ROOTDIR}/linux-x-server-viv
ATHDIR=${ROOTDIR}/linux-atheros-wifi/3.1/AR6kSDK.build_3.1_RC.563/host

all_one_branch=n

TOOL_CHAIN=/opt/freescale/usr/local/gcc-4.6.2-glibc-2.13-linaro-multilib-2011.12/fsl-linaro-toolchain/bin/
export PATH=$PATH:/opt/freescale/usr/local/gcc-4.6.2-glibc-2.13-linaro-multilib-2011.12/fsl-linaro-toolchain/bin/

RC=0

#below is the matrix for rootfs
declare -a kernel_branch;
declare -a vte_branch;
declare -a plat_name;
declare -a soc_name;
declare -a u_boot_configs;
declare -a kernel_configs;
declare -a vte_configs;
declare -a unit_test_configs;
declare -a rootfs_apd;
declare -a rootfs;
declare -a gpu_branch;
declare -a exa_branch;
declare -a gpu_configs;
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
kernel_branch=("imx_2.6.35" "imx_2.6.35" "imx_2.6.35" "imx_2.6.35" "imx_2.6.35" "imx_2.6.35" \
"imx_2.6.35" "imx_2.6.35" "imx_2.6.35" "imx_2.6.35" "imx_2.6.35" "imx_3.0.35" "imx_3.0.35" \
"imx_3.0.35" "imx_3.0.35" "imx_3.0.35" "imx_3.0.35" "imx_3.0.35" "imx_3.0.35"  "imx_3.0.35");
vte_branch=("imx2.6.35.3" "imx2.6.35.3" "imx2.6.35.3" "imx2.6.35.3" "imx2.6.35.3" "imx2.6.35.3" \
"imx2.6.35.3" "imx2.6.35.3" "imx2.6.35.3" "imx2.6.35.3" "imx2.6.35.3" "master" "master" "master" \
"master" "master" "master" "master" "master" "master");
gpu_branch=("" "" "" "" "" "" "" "" "" "" "" "multicore" "multicore" "multicore" "multicore" \
"multicore" "multicore" "multicore" "multicore" "multicore");
exa_branch=("" "" "" "" "" "" "" "" "" "" "" "master" "master" "master" "master" \
"master" "master" "master" "master" "master");
plat_name=("IMX23EVK" "IMX25-3STACK" "IMX28EVK" "IMX31-3STACK" "IMX35-3STACK" \
"IMX37-3STACK" "IMX50RDP" "IMX50-RDP3"  "IMX51-BABBAGE" "IMX53SMD" "IMX53LOCO" \
"IMX6-SABREAUTO" "IMX6-SABRELITE" "IMX6ARM2" "IMX6Q-Sabre-SD" "IMX6DL-ARM2" \
"IMX6DL-Sabre-SD"  "IMX6Solo-SABREAUTO" "IMX6Sololite-ARM2" "IMX6SL-EVK");
test_plan=("_" "_" "_" "_" "_" "_" "_" "_" "_" "_" "_" "_AI_" "_lite_" \
"_ARM2_" "_SMD_" "_ARM2_" "_SMD_" "_AI_" "_ARM2_" "_EVK_");
soc_name=("233" "25" "28" "31" "35" "37" "50"  "50" "51" "53" "53" "63" "63" \
"63" "63" "61" "61" "61" "60" "60");
#default u-boot kernel configs for each platform
u_boot_configs=("mx23_evk_config" "mx25_3stack_config" "mx28_evk_config" \
"mx31_3stack_config" "mx35_3stack_config" "mx31_3stack_config" \
"mx50_rdp_config" "mx50_rd3_config"  "mx51_bbg_config" "mx53_smd_config" "mx53_loco_config" \
"mx6q_sabreauto_config" "mx6q_sabrelite_config" "mx6q_arm2_config" "mx6q_sabresd_config"  \
"mx6dl_arm2_config" "mx6dl_sabresd_config" "mx6solo_sabreauto_config" "mx6sl_arm2_config" "mx6sl_evk_config");
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
#unit_test_configs
unit_test_configs=("IMX233" "IMX25" "IMX28" "IMX3" "IMX3" "IMX3" "IMX5" \
"IMX5" "IMX5" "IMX51" "IMX53" "IMX6" "IMX6" "IMX6" "IMX6" "IMX6" "IMX6" "IMX6" "IMX6" "IMX6");
#linux_libs_platfm
linux_libs_platfm=("NULL" "NULL" "NULL" "NULL" "NULL" "IMX37_3STACK" "NULL" \
"NULL" "IMX51" "IMX53" "IMX53" "IMX6Q" "IMX6Q" "IMX6Q" "IMX6Q" "IMX6Q" \
"IMX6Q" "IMX6Q" "IMX6Q" "IMX6Q");
linux_libs_branch=("master" "master" "master" "master" "master" "master" "master" \
"master" "master" "master" "master" "master" "master" "master" "master" "master" \
"master" "master" "master" "master");
#rootfs and vte apendix
rootfs_apd=("" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "");
xrootfs=("" "" "" "" "" "" "" "" "" "" "" "ubuntu_11.10_d" "ubuntu_11.10_d" "ubuntu_11.10_d" "ubuntu_11.10_d" "ubuntu_11.10_d" "ubuntu_11.10_d" "ubuntu_11.10_d" "ubuntu_11.10_sd" "ubuntu_11.10_sd")
gpu_configs=("0" "0" "0" "0" "0" "0" "0" "0" "0" "0" "0" "1" "1" "1" "1" "1" "1" "1" "1" "1");
target_configs=("0" "0" "0" "0" "0" "0" "0" "0" "0" "0" "0" "0" "0" "0" "0" "0" "0" "0" "0" "0");
vte_target_configs=("0" "0" "0" "0" "0" "0" "0" "0" "0" "0" "0" "1" "1" "1" "1" "1" "1" "1" "1" "1");

branch_atheros()
{
  cd $ROOTDIR
  if [ ! -e $ATHDIR ]; then
   git clone git://sw-git.freescale.net/linux-atheros-wifi.git
  fi
  cd $ATHDIR
  git checkout master
  git pull 
}

make_atheors()
{
 cd $ATHDIR
  git add . 
  git commit -s -m"reset"
  git reset --hard HEAD~1
  git checkout -b temp  origin/master || git checkout temp
  git add . && git commit -s -m"reset" && git reset --hard HEAD~1 
  git branch -D build
  git fetch origin +master:build && git checkout build || return 1
  git branch -D build
  git checkout build || git add . && git commit -s -m"build $(date +%m%d)" && git checkout build
  git checkout -b build_target build

 make WORKAREA=$(pwd) ATH_LINUXPATH=${KERNEL_DIR} ARCH=arm CROSS_COMPILE=${TOOL_CHAIN}arm-none-linux-gnueabi- clean 
 make WORKAREA=$(pwd) ATH_LINUXPATH=${KERNEL_DIR} ARCH=arm CROSS_COMPILE=${TOOL_CHAIN}arm-none-linux-gnueabi- 
}

install_atheors()
{
 sudo mkdir -p ${1}/lib/modules/${2}/extra
 sudo cp ${ATHDIR}/os/linux/ar6000.ko ${1}/lib/modules/${2}/extra/
 cd ${1}
 sudo depmod -b ${1} ${2}
}


branch_libs()
{
  cd $ROOTDIR
  if [ ! -e $LIB_DIR ]; then
   git clone git://sw-git.freescale.net/linux-lib.git
  fi
  cd $LIB_DIR
  git checkout master
  git pull 
}

make_libs()
{
  iRC=0
  if [ "$old_libs_config" = "${1}${2}" ]; then
   if [ "old_libs_target" = "${3}${4}"  ]; then
	echo "libs deployed already"
        return $iRC
   fi
  sudo make DEST_DIR=${TARGET_ROOTFS}/imx${3}_rootfs${4} install -k || iRC=$(expr $iRC + 1)
 	if [ $deploy_target_rd -eq 1 ]; then
  sudo make DEST_DIR=${TARGET_ROOTFS_RD}/imx${3}_rootfs${4} install -k || iRC=$(expr $iRC + 1)
	fi
     return $iRC
  fi

  old_libs_config=${1}${2}
  old_libs_target=${3}${4}
  cd $LIB_DIR
  git add . 
  git commit -s -m"reset"
  git reset --hard HEAD~1
  git checkout -b temp  origin/$1 || git checkout temp
  git add . && git commit -s -m"reset" && git reset --hard HEAD~1 
  git branch -D build
  git fetch origin +$1:build && git checkout build || return 1
  git branch -D build_${2}
  git checkout build || git add . && git commit -s -m"build $(date +%m%d)" && git checkout build
  git checkout -b build_${2} build
  make clean
  make PLATFORM=${2} CROSS_COMPILE=${TOOL_CHAIN}arm-none-linux-gnueabi- INCLUDE="-I${KERNEL_DIR}/include -I${KERNEL_DIR}/drivers/mxc/security/rng/include -I${KERNEL_DIR}/drivers/mxc/security/sahara2/include" -k || iRC=1
  sudo make DEST_DIR=${TARGET_ROOTFS}/imx${3}_rootfs${4} install -k || iRC=$(expr $iRC + 1)
 	if [ $deploy_target_rd -eq 1 ]; then
  sudo make DEST_DIR=${TARGET_ROOTFS_RD}/imx${3}_rootfs${4} install -k || iRC=$(expr $iRC + 1)
	fi
  return $iRC
}


deploy_firmware()
{
  cd $ROOTDIR
  if [ ! -e $FIRMWARE_DIR ]; then
    git clone git://sw-git.freescale.net/linux-firmware-imx.git
  fi
  cd $FIRMWARE_DIR
  git checkout master && git pull
  if [ -e ${FIRMWARE_DIR}/firmware ]; then
    sudo rm -rf ${TARGET_ROOTFS}/imx${1}_rootfs${2}/lib/firmware
    sudo cp -af ${FIRMWARE_DIR}/firmware ${TARGET_ROOTFS}/imx${1}_rootfs${2}/lib/ || return 1
 	if [ $deploy_target_rd -eq 1 ]; then
    sudo rm -rf ${TARGET_ROOTFS_RD}/imx${1}_rootfs${2}/lib/firmware
    sudo cp -af ${FIRMWARE_DIR}/firmware ${TARGET_ROOTFS_RD}/imx${1}_rootfs${2}/lib/ || return 1
 	fi
  fi 
  return 0
}

make_unit_test()
{
 cd $UNITTEST_DIR
 if [ $old_ut_plat = $2 ]; then
	return $old_ut_rc
 fi
 cat all-suite.txt | grep -v "#" | grep $1 > unit_test
 while read LINE; do
  platform=$(cat $LINE | grep -v "#" |cut -d ":" -f 3)
  if [ -z "$platform" ];then
    if [ ! -z $(cat $LINE | grep -v "#") ]; then
    echo $LINE >> unit_test
    fi
  fi
 done < all-suite.txt

 sed -i 's/:/\t/g' unit_test
 ucs=$(cat unit_test | grep -i FSL-UT | wc -l)
 if [ $ucs -ne 9 ];then
    echo "VTE daily build found $2 unit test change" | mutt -s "the unit test count is $ucs changed" \
		b20222@freescale.com 
 fi
 #sudo cp unit_test ${VTE_TARGET_PRE}/vte_mx${2}_${3}d/runtest/
 sudo cp unit_test ${VTE_TARGET_PRE2}/vte_mx${2}_${3}d/runtest/
 if [ $deploy_vte_target_rd -eq 1 ]; then
 sudo cp unit_test ${VTE_TARGET_PRE3}/vte_mx${2}_${3}d/runtest/
 fi
 old_ut_plat=$2
 old_ut_rc=0
 PLATFORM=$1
 KERNELDIR=$KERNEL_DIR
 KBUILD_OUTPUT=$KERNEL_DIR
 INCLUDE="-I${TARGET_ROOTFS}/imx${2}_rootfs${3}/usr/include \
 -I${TARGET_ROOTFS}/imx${2}_rootfs${3}/usr/src/linux/include \
 -I./include/"
 LIB="-L${TARGET_ROOTFS}/imx${2}_rootfs${3}/usr/lib"
 make distclean
 make -C module_test KBUILD_OUTPUT=$KBUILD_OUTPUT LINUXPATH=$KERNELDIR  CC=${TOOL_CHAIN}arm-none-linux-gnueabi-gcc \
 CROSS_COMPILE=${TOOL_CHAIN}arm-none-linux-gnueabi- || old_ut_rc=1
 make -j1 PLATFORM=$PLATFORM INC="${INCLUDE}" LIBS=${LIB} test  CC=${TOOL_CHAIN}arm-none-linux-gnueabi-gcc \
 CROSS_COMPILE=${TOOL_CHAIN}arm-none-linux-gnueabi- || old_ut_rc=$(expr $old_ut_rc + 2)
 sudo make -C module_test -j1 LINUXPATH=$KERNELDIR KBUILD_OUTPUT=$KBUILD_OUTPUT \
 CROSS_COMPILE=${TOOL_CHAIN}arm-none-linux-gnueabi- \
 DEPMOD=/bin/true INSTALL_MOD_PATH=${TARGET_ROOTFS}/imx${2}_rootfs${3} install -k || old_ut_rc=$(expr $old_ut_rc + 4)
 sudo  make PLATFORM=$PLATFORM DESTDIR=${TARGET_ROOTFS}/imx${2}_rootfs${3}/unit_tests \
 CROSS_COMPILE=${TOOL_CHAIN}arm-none-linux-gnueabi- install || old_ut_rc=$(expr $old_ut_rc + 8)
 if [ $deploy_target_rd -eq 1 ]; then
 sudo make -C module_test -j1 LINUXPATH=$KERNELDIR KBUILD_OUTPUT=$KBUILD_OUTPUT \
 CROSS_COMPILE=${TOOL_CHAIN}arm-none-linux-gnueabi- \
 DEPMOD=/bin/true INSTALL_MOD_PATH=${TARGET_ROOTFS_RD}/imx${2}_rootfs${3} install -k || old_ut_rc=$(expr $old_ut_rc + 5)
 sudo  make PLATFORM=$PLATFORM DESTDIR=${TARGET_ROOTFS_RD}/imx${2}_rootfs${3}/unit_tests \
 CROSS_COMPILE=${TOOL_CHAIN}arm-none-linux-gnueabi- install || old_ut_rc=$(expr $old_ut_rc + 8)
 fi
 return $old_ut_rc
}

make_uboot_config()
{
echo "make uboot config $1"
cd $UCONFDIR
sed "/UVERSION/s/^.*/UVERSION=$2/g" u-boot-${1}-conf.txt > ${1}-config.txt
make clean
make  CC=gcc PLATFORM=MX$3
$UCONFDIR/u-config -s ${1}-config.txt u-boot-${1}-config.bin
$UCONFDIR/u-config -s ${1}-config_rd.txt u-boot-${1}-config_rd.bin
#rm -f ${1}_config.txt
sudo cp u-boot-${1}-config.bin ${TARGET_ROOTFS}/imx${3}_rootfs${4}/root/u-boot-${1}-config.bin || return 3
 if [ $deploy_target_rd -eq 1 ]; then
sudo cp u-boot-${1}-config.bin ${TARGET_ROOTFS_RD}/imx${3}_rootfs${4}/root/u-boot-${1}-config_rd.bin || return 3
rm -rf  u-boot-${1}-config_rd.bin
 fi
rm -rf  u-boot-${1}-config.bin
}

make_uboot()
{
echo "make uboot $2 with $1"
cd $UBOOT_DIR
make ARCH=arm CROSS_COMPILE=${TOOL_CHAIN}arm-none-linux-gnueabi- distclean
make ARCH=arm CROSS_COMPILE=${TOOL_CHAIN}arm-none-linux-gnueabi- $1 || return 1
make ARCH=arm CROSS_COMPILE=${TOOL_CHAIN}arm-none-linux-gnueabi- || return 2
sudo cp  u-boot.bin /tftpboot/u-boot-${3}_d.bin
sudo cp u-boot.bin ${TARGET_ROOTFS}/imx${2}_rootfs${4}/root/u-boot-${3}_d.bin || return 3
make_uboot_config $3 $(git log | head -1 | cut -d " " -f 2 | cut -c 1-6) $2 $4 || return 3 
return 0
}

make_exa()
{
if [ $1 -eq 0 ];then
 return 0
fi
echo "make exa driver $2 with $1"
cd $EXA_DIR
if [ "$old_exa_config" = $1 ];then
if [ "$old_exa_rc" -eq 0 ]; then
  if [ $old_exa_target = "${2}${3}" ]; then
	echo "already deployed"
	return $old_exa_rc
  fi
  sudo make install
fi
return $old_exa_rc
fi
old_exa_config=$1
old_exa_target=${2}${3}
git branch -D build_${2}
git checkout build || git add . && git commit -s -m"build $(date +%m%d)" && git checkout build
git checkout -b build_${2} build
old_exa_rc=0
export CROSS_COMPILE=${TOOL_CHAIN}arm-none-linux-gnueabi-
export ROOTFS=${TARGET_ROOTFS}/${3}
export CFLAGS="-I${ROOTFS}/usr/include "
export LDFLAGS="-L${ROOTFS}/usr/lib -Xlinker -rpath-link=${ROOTFS}/usr/lib  -lGAL -lpthread -lm -lX11"
export PKG_CONFIG_PATH=${ROOTFS}/usr/share/pkgconfig
export XORG_CFLAGS="-I${ROOTFS}/usr/include/xorg/ -I${ROOTFS}/usr/include/pixman-1"
srcdir=${EXA_DIR}
autoreconf --force --install --verbose "$srcdir"
./configure --host=arm-none-linux-gnueabi --prefix=${ROOTFS}/usr --disable-static CC=${CROSS_COMPILE}gcc
make || old_exa_rc=1
sudo make install
unset  CFLAGS LDFLAGS PKG_CONFIG_PATH XORG_CFLAGS
return $old_exa_rc
}

make_gpu_x()
{
if [ $1 -eq 0 ];then
 return 0
fi
echo "make gpu driver $2 with $1"
cd $GPU_DIR/driver
if [ "$old_gpu_config" = $1 ];then
if [ "$old_gpu_rc" -eq 0 ]; then
  if [ $old_gpu_target = "${2}${3}" ]; then
	echo "already deployed"
	return $old_gpu_rc
  fi
sudo cp -a $GPU_DIR/build/sdk/drivers/* ${TARGET_ROOTFS}/${3}/usr/lib/
fi
return $old_gpu_rc
fi
old_gpu_config=$1
old_gpu_target=${2}${3}
git branch -D build_${2}
git checkout build || git add . && git commit -s -m"build $(date +%m%d)" && git checkout build
git checkout -b build_${2} build

export X11_ARM_DIR=${TARGET_ROOTFS}/${3}/usr
export BUILD_OPTION_EGL_API_FB=0
export ARCH=arm
export AQROOT=${GPU_DIR}/driver
export AQARCH=${AQROOT}/arch/XAQ2
export AQVGARCH=${AQROOT}/arch/GC350
export SDK_DIR=${AQROOT}/build/sdk
export USE_355_VG=1
#export DFB_DIR=/mnt/nfs_root/imx${2}_rootfs${3}/usr
export ARCH_TYPE=$ARCH
export CPU_TYPE=cortex-a9
export FIXED_ARCH_TYPE=arm

export KERNEL_DIR=${KERNEL_DIR}
export CROSS_COMPILE=${TOOL_CHAIN}arm-none-linux-gnueabi-
LD_OPTION_DEBUG=0
BUILD_OPTION_ABI=0
BUILD_OPTION_LINUX_OABI=0
BUILD_OPTION_NO_DMA_COHERENT=0
BUILD_OPTION_USE_VDK=1
if [ -z $BUILD_OPTION_EGL_API_FB ]; then
    BUILD_OPTION_EGL_API_FB=1
fi
BUILD_OPTION_gcdSTATIC_LINK=0
BUILD_OPTION_CUSTOM_PIXMAP=0
BUILD_OPTION_USE_3D_VG=1
BUILD_OPTION_USE_OPENCL=1
BUILD_OPTION_USE_FB_DOUBLE_BUFFER=0
BUILD_OPTION_USE_PLATFORM_DRIVER=1
BUILD_OPTION_ENABLE_GPU_CLOCK_BY_DRIVER=1
BUILD_OPTION_CONFIG_DOVEXC5_BOARD=0
BUILD_OPTION_FPGA_BUILD=0
BUILD_OPTION_USE_PROFILER=0
BUILD_OPTION_VIVANTE_ENABLE_VG=1
BUILD_OPTION_USE_355_VG=1
BUILD_OPTION_DIRECTFB_MAJOR_VERSION=1
BUILD_OPTION_DIRECTFB_MINOR_VERSION=4
BUILD_OPTION_DIRECTFB_MICRO_VERSION=0

BUILD_OPTIONS="NO_DMA_COHERENT=$BUILD_OPTION_NO_DMA_COHERENT"
BUILD_OPTIONS="$BUILD_OPTIONS USE_VDK=$BUILD_OPTION_USE_VDK"
BUILD_OPTIONS="$BUILD_OPTIONS EGL_API_FB=$BUILD_OPTION_EGL_API_FB"
BUILD_OPTIONS="$BUILD_OPTIONS gcdSTATIC_LINK=$BUILD_OPTION_gcdSTATIC_LINK"
BUILD_OPTIONS="$BUILD_OPTIONS ABI=$BUILD_OPTION_ABI"
BUILD_OPTIONS="$BUILD_OPTIONS LINUX_OABI=$BUILD_OPTION_LINUX_OABI"
BUILD_OPTIONS="$BUILD_OPTIONS DEBUG=$BUILD_OPTION_DEBUG"
BUILD_OPTIONS="$BUILD_OPTIONS CUSTOM_PIXMAP=$BUILD_OPTION_CUSTOM_PIXMAP"
BUILD_OPTIONS="$BUILD_OPTIONS USE_3D_VG=$BUILD_OPTION_USE_3D_VG"
BUILD_OPTIONS="$BUILD_OPTIONS USE_OPENCL=$BUILD_OPTION_USE_OPENCL"
BUILD_OPTIONS="$BUILD_OPTIONS USE_FB_DOUBLE_BUFFER=$BUILD_OPTION_USE_FB_DOUBLE_BUFFER"
BUILD_OPTIONS="$BUILD_OPTIONS USE_PLATFORM_DRIVER=$BUILD_OPTION_USE_PLATFORM_DRIVER"
BUILD_OPTIONS="$BUILD_OPTIONS ENABLE_GPU_CLOCK_BY_DRIVER=$BUILD_OPTION_ENABLE_GPU_CLOCK_BY_DRIVER"
BUILD_OPTIONS="$BUILD_OPTIONS CONFIG_DOVEXC5_BOARD=$BUILD_OPTION_CONFIG_DOVEXC5_BOARD"
BUILD_OPTIONS="$BUILD_OPTIONS FPGA_BUILD=$BUILD_OPTION_FPGA_BUILD"
BUILD_OPTIONS="$BUILD_OPTIONS USE_PROFILER=$BUILD_OPTION_USE_PROFILER"
BUILD_OPTIONS="$BUILD_OPTIONS VIVANTE_ENABLE_VG=$BUILD_OPTION_VIVANTE_ENABLE_VG"
BUILD_OPTIONS="$BUILD_OPTIONS USE_355_VG=$BUILD_OPTION_USE_355_VG"
BUILD_OPTIONS="$BUILD_OPTIONS DIRECTFB_MAJOR_VERSION=$BUILD_OPTION_DIRECTFB_MAJOR_VERSION"
BUILD_OPTIONS="$BUILD_OPTIONS DIRECTFB_MINOR_VERSION=$BUILD_OPTION_DIRECTFB_MINOR_VERSION"
BUILD_OPTIONS="$BUILD_OPTIONS DIRECTFB_MICRO_VERSION=$BUILD_OPTION_DIRECTFB_MICRO_VERSION"

export PATH=$TOOLCHAIN/bin:$PATH
export AQVGARCH=$AQROOT/arch/GC350
export VIVANTE_ENABLE_VG=1
export ROOTFS_USR=${X11_ARM_DIR}
old_gpu_rc=0
cd $AQROOT; make -j1 -f makefile.linux $BUILD_OPTIONS clean
cd $AQROOT; make -j1 -f makefile.linux $BUILD_OPTIONS install 2>&1 || old_gpu_rc=gpux_${2}
sudo cp -a $GPU_DIR/driver/build/sdk/drivers/* ${TARGET_ROOTFS}/${3}/usr/lib/
sudo cp ${GPU_DIR}/driver/openGL/libGL2/script/xorg.conf ${TARGET_ROOTFS}/${3}/etc/
sudo mkdir  ${TARGET_ROOTFS}/${3}/usr/lib/dri
sudo cp  $GPU_DIR/driver/build/sdk/drivers/vivante_dri.so  ${TARGET_ROOTFS}/${3}/usr/lib/dri/
sudo cp $GPU_DIR/driver/build/sdk/drivers/libGL.so.1.2 ${TARGET_ROOTFS}/${3}/usr/lib/
cd ${TARGET_ROOTFS}/${3}/usr/lib/
sudo rm -rf libGL.so 
sudo ln -s libGL.so.1.2 libGL.so
unset BUILD_OPTION_EGL_API_FB
return 0
}

make_gpu()
{
if [ $1 -eq 0 ];then
 return 0
fi
echo "make gpu driver $2 with $1"
cd $GPU_DIR/driver
if [ "$old_gpu_config" = $1 ];then
if [ "$old_gpu_rc" -eq 0 ]; then
  if [ $old_gpu_target = "${2}${3}" ]; then
	echo "already deployed"
	return $old_gpu_rc
  fi
sudo cp -a $GPU_DIR/build/sdk/drivers/* ${TARGET_ROOTFS}/imx${2}_rootfs${3}/usr/lib/
 if [ $deploy_target_rd -eq 1 ]; then
sudo cp -a $GPU_DIR/build/sdk/drivers/* ${TARGET_ROOTFS_RD}/imx${2}_rootfs${3}/usr/lib/
  fi
fi
return $old_gpu_rc
fi
old_gpu_config=$1
old_gpu_target=${2}${3}
git branch -D build_${2}
git checkout build || git add . && git commit -s -m"build $(date +%m%d)" && git checkout build
git checkout -b build_${2} build

export ARCH=arm
export AQROOT=${GPU_DIR}/driver
export AQARCH=${AQROOT}/arch/XAQ2
export AQVGARCH=${AQROOT}/arch/GC350
export SDK_DIR=${AQROOT}/build/sdk
export USE_355_VG=1
export DFB_DIR=${TARGET_ROOTFS}/imx${2}_rootfs${3}/usr
export ARCH_TYPE=$ARCH
export CPU_TYPE=cortex-a9
export FIXED_ARCH_TYPE=arm

export KERNEL_DIR=${KERNEL_DIR}
export CROSS_COMPILE=${TOOL_CHAIN}arm-none-linux-gnueabi-
LD_OPTION_DEBUG=0
BUILD_OPTION_ABI=0
BUILD_OPTION_LINUX_OABI=0
BUILD_OPTION_NO_DMA_COHERENT=0
BUILD_OPTION_USE_VDK=1
if [ -z $BUILD_OPTION_EGL_API_FB ]; then
    BUILD_OPTION_EGL_API_FB=1
fi
BUILD_OPTION_gcdSTATIC_LINK=0
BUILD_OPTION_CUSTOM_PIXMAP=0
BUILD_OPTION_USE_3D_VG=1
BUILD_OPTION_USE_OPENCL=1
BUILD_OPTION_USE_FB_DOUBLE_BUFFER=0
BUILD_OPTION_USE_PLATFORM_DRIVER=1
BUILD_OPTION_ENABLE_GPU_CLOCK_BY_DRIVER=1
BUILD_OPTION_CONFIG_DOVEXC5_BOARD=0
BUILD_OPTION_FPGA_BUILD=0
BUILD_OPTION_USE_PROFILER=0
BUILD_OPTION_VIVANTE_ENABLE_VG=1
BUILD_OPTION_USE_355_VG=1
BUILD_OPTION_DIRECTFB_MAJOR_VERSION=1
BUILD_OPTION_DIRECTFB_MINOR_VERSION=4
BUILD_OPTION_DIRECTFB_MICRO_VERSION=0

BUILD_OPTIONS="NO_DMA_COHERENT=$BUILD_OPTION_NO_DMA_COHERENT"
BUILD_OPTIONS="$BUILD_OPTIONS USE_VDK=$BUILD_OPTION_USE_VDK"
BUILD_OPTIONS="$BUILD_OPTIONS EGL_API_FB=$BUILD_OPTION_EGL_API_FB"
BUILD_OPTIONS="$BUILD_OPTIONS gcdSTATIC_LINK=$BUILD_OPTION_gcdSTATIC_LINK"
BUILD_OPTIONS="$BUILD_OPTIONS ABI=$BUILD_OPTION_ABI"
BUILD_OPTIONS="$BUILD_OPTIONS LINUX_OABI=$BUILD_OPTION_LINUX_OABI"
BUILD_OPTIONS="$BUILD_OPTIONS DEBUG=$BUILD_OPTION_DEBUG"
BUILD_OPTIONS="$BUILD_OPTIONS CUSTOM_PIXMAP=$BUILD_OPTION_CUSTOM_PIXMAP"
BUILD_OPTIONS="$BUILD_OPTIONS USE_3D_VG=$BUILD_OPTION_USE_3D_VG"
BUILD_OPTIONS="$BUILD_OPTIONS USE_OPENCL=$BUILD_OPTION_USE_OPENCL"
BUILD_OPTIONS="$BUILD_OPTIONS USE_FB_DOUBLE_BUFFER=$BUILD_OPTION_USE_FB_DOUBLE_BUFFER"
BUILD_OPTIONS="$BUILD_OPTIONS USE_PLATFORM_DRIVER=$BUILD_OPTION_USE_PLATFORM_DRIVER"
BUILD_OPTIONS="$BUILD_OPTIONS ENABLE_GPU_CLOCK_BY_DRIVER=$BUILD_OPTION_ENABLE_GPU_CLOCK_BY_DRIVER"
BUILD_OPTIONS="$BUILD_OPTIONS CONFIG_DOVEXC5_BOARD=$BUILD_OPTION_CONFIG_DOVEXC5_BOARD"
BUILD_OPTIONS="$BUILD_OPTIONS FPGA_BUILD=$BUILD_OPTION_FPGA_BUILD"
BUILD_OPTIONS="$BUILD_OPTIONS USE_PROFILER=$BUILD_OPTION_USE_PROFILER"
BUILD_OPTIONS="$BUILD_OPTIONS VIVANTE_ENABLE_VG=$BUILD_OPTION_VIVANTE_ENABLE_VG"
BUILD_OPTIONS="$BUILD_OPTIONS USE_355_VG=$BUILD_OPTION_USE_355_VG"
BUILD_OPTIONS="$BUILD_OPTIONS DIRECTFB_MAJOR_VERSION=$BUILD_OPTION_DIRECTFB_MAJOR_VERSION"
BUILD_OPTIONS="$BUILD_OPTIONS DIRECTFB_MINOR_VERSION=$BUILD_OPTION_DIRECTFB_MINOR_VERSION"
BUILD_OPTIONS="$BUILD_OPTIONS DIRECTFB_MICRO_VERSION=$BUILD_OPTION_DIRECTFB_MICRO_VERSION"

export PATH=$TOOLCHAIN/bin:$PATH
export AQVGARCH=$AQROOT/arch/GC350
export VIVANTE_ENABLE_VG=1

old_gpu_rc=0
cd $AQROOT; make -j1 -f makefile.linux $BUILD_OPTIONS clean
cd $AQROOT; make -j1 -f makefile.linux $BUILD_OPTIONS install 2>&1 || old_gpu_rc=gpu_${2}
sudo cp -a $GPU_DIR/driver/build/sdk/drivers/* ${TARGET_ROOTFS}/imx${2}_rootfs${3}/usr/lib/
 if [ $deploy_target_rd -eq 1 ]; then
sudo cp -a $GPU_DIR/driver/build/sdk/drivers/* ${TARGET_ROOTFS_RD}/imx${2}_rootfs${3}/usr/lib/
 fi
return 0
}

make_kernel()
{
echo "make Platform $2 with $1"
cd $KERNEL_DIR
if [ "$old_kernel_config" = $1 ];then
if [ "$old_kernel_rc" -eq 0 ]; then
  if [ "$old_kernel_target" = "${2}${3}"  ]; then
	return $old_kernel_rc
  fi
#sudo rm -rf ${TARGET_ROOTFS}/imx${2}_rootfs/lib/modules/*-daily*
sudo make ARCH=arm modules_install INSTALL_MOD_PATH=${TARGET_ROOTFS}/imx${2}_rootfs${3} || return 3
sudo make ARCH=arm modules_install INSTALL_MOD_PATH=${TARGET_ROOTFS}/${4} || return 3
 if [ $deploy_target_rd -eq 1 ]; then
sudo make ARCH=arm modules_install INSTALL_MOD_PATH=${TARGET_ROOTFS_RD}/imx${2}_rootfs${3} || return 3
  fi
md5sum arch/arm/boot/uImage
sudo cp  arch/arm/boot/uImage /tftpboot/uImage_mx${2}_${3}d
sudo cp $KERNEL_DIR/tools/perf/perf ${TARGET_ROOTFS}/imx${2}_rootfs${3}/usr/bin/
 install_atheors ${TARGET_ROOTFS}/imx${2}_rootfs${3} $KERNEL_VER 
 install_atheors ${TARGET_ROOTFS}/${4} $KERNEL_VER 
 if [ $deploy_target_rd -eq 1 ]; then
sudo cp $KERNEL_DIR/tools/perf/perf ${TARGET_ROOTFS_RD}/imx${2}_rootfs${3}/usr/bin/
 install_atheors ${TARGET_ROOTFS}/imx${2}_rootfs${3} $KERNEL_VER 
  fi
fi
return $old_kernel_rc
fi
old_kernel_config=$1
old_kernel_target=${2}${3}
git branch -D build_${2}
git checkout build || git add . && git commit -s -m"build $(date +%m%d)" && git checkout build
git checkout -b build_${2} build
make distclean
echo "-daily"  > localversion
make ARCH=arm CROSS_COMPILE=${TOOL_CHAIN}arm-none-linux-gnueabi- $1 || return 1
make ARCH=arm CROSS_COMPILE=${TOOL_CHAIN}arm-none-linux-gnueabi- -j 2 uImage|| return 2
#KERNEL_VER=$(./scripts/setlocalversion)
#sudo rm -rf ${TARGET_ROOTFS}/imx${2}_rootfs${3}/lib/modules/*-daily*
make ARCH=arm CROSS_COMPILE=${TOOL_CHAIN}arm-none-linux-gnueabi- -j 2 modules|| return 4
sudo make ARCH=arm modules_install INSTALL_MOD_PATH=${TARGET_ROOTFS}/imx${2}_rootfs${3} || return 3
sudo make ARCH=arm headers_install INSTALL_HDR_PATH=${TARGET_ROOTFS}/imx${2}_rootfs${3}/usr/src/linux/ || return 5
sudo make ARCH=arm modules_install INSTALL_MOD_PATH=${TARGET_ROOTFS}/${4} || return 3
 if [ $deploy_target_rd -eq 1 ]; then
sudo make ARCH=arm modules_install INSTALL_MOD_PATH=${TARGET_ROOTFS_RD}/imx${2}_rootfs${3} || return 3
sudo make ARCH=arm headers_install INSTALL_HDR_PATH=${TARGET_ROOTFS_RD}/imx${2}_rootfs${3}/usr/src/linux/ || return 5
 fi
md5sum arch/arm/boot/uImage
sudo cp arch/arm/boot/uImage /tftpboot/uImage_mx${2}_${3}d
cd $KERNEL_DIR/tools/perf/
make ARCH=arm CROSS_COMPILE=${TOOL_CHAIN}arm-none-linux-gnueabi- CFLAGS="-static -DGElf_Nhdr=Elf32_Nhdr"
sudo cp  perf ${TARGET_ROOTFS}/imx${2}_rootfs${3}/usr/bin/
 if [ $deploy_target_rd -eq 1 ]; then
  sudo cp  perf ${TARGET_ROOTFS_RD}/imx${2}_rootfs${3}/usr/bin/
  fi 
  cd $KERNEL_DIR
  KERNEL_VER=$(cat include/config/kernel.release 2>/dev/null)
 make_atheors 
 install_atheors ${TARGET_ROOTFS}/imx${2}_rootfs${3} $KERNEL_VER 
 install_atheors ${4} $KERNEL_VER 
 if [ $deploy_target_rd -eq 1 ]; then
    install_atheors ${TARGET_ROOTFS}/imx${2}_rootfs${3} $KERNEL_VER 
 fi 
old_kernel_rc=0
return 0
}

sync_testcase()
{
 php $ROOTDIR/skywalker/vte_script/client_skywalker_case.php $1 > ${ROOTDIR}/${2}
 lines=$(cat ${ROOTDIR}/$2 | wc -l)
 if [ $line -gt 1 ]; then
	#sudo cp ${ROOTDIR}/${2} ${VTE_TARGET_PRE}/vte_mx${3}_${4}d/runtest/  
	#sudo cp ${ROOTDIR}/${2} ${VTE_TARGET_PRE}/vte_mx${3}/runtest/  
	sudo cp ${ROOTDIR}/${2} ${VTE_TARGET_PRE2}/vte_mx${3}_${4}d/runtest/  
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
   sudo cp -a install/* ${VTE_TARGET_PRE2}/vte_mx${2}_${3}d/
   sudo cp -a testcases/bin/* ${VTE_TARGET_PRE2}/vte_mx${2}_${3}d/testcases/bin/
   sudo cp mytest ${VTE_TARGET_PRE2}/vte_mx${2}_${3}d/
   if [ $deploy_vte_target_rd -eq 1 ]; then
   sudo cp -a install/* ${VTE_TARGET_PRE3}/vte_mx${2}_${3}d/
   sudo cp -a testcases/bin/* ${VTE_TARGET_PRE3}/vte_mx${2}_${3}d/testcases/bin/
   sudo cp mytest ${VTE_TARGET_PRE3}/vte_mx${2}_${3}d/
   fi
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
export KLINUX_SRCDIR=${TARGET_ROOTFS}/imx${2}_rootfs${3}/usr/src/linux/
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
sudo cp -a install/* ${VTE_TARGET_PRE2}/vte_mx${2}_${3}d/
sudo cp -a testcases/bin/* ${VTE_TARGET_PRE2}/vte_mx${2}_${3}d/testcases/bin/
sudo cp mytest ${VTE_TARGET_PRE2}/vte_mx${2}_${3}d/
if [ $deploy_vte_target_rd -eq 1 ]; then
sudo cp -a install/* ${VTE_TARGET_PRE3}/vte_mx${2}_${3}d/
sudo cp -a testcases/bin/* ${VTE_TARGET_PRE3}/vte_mx${2}_${3}d/testcases/bin/
sudo cp mytest ${VTE_TARGET_PRE3}/vte_mx${2}_${3}d/
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

update_rootfs()
{	
 cd $SCRPTSDIR
 sudo cp vte ${TARGET_ROOTFS}/imx${1}_rootfs${2}/etc/rc.d/init.d/vte 	
 if [ $deploy_target_rd -eq 1 ]; then
 sudo cp vte_rd ${TARGET_ROOTFS_RD}/imx${1}_rootfs${2}/etc/rc.d/init.d/vte 	
 fi
 deploy_firmware $1 $2
}

make_target_tools()
{
 cd $TOOLSDIR
 make clean
 CROSS_COMPILER=${TOOL_CHAIN}arm-none-linux-gnueabi- make || return 10
 #sudo cp uclient ${VTE_TARGET_PRE}/tools/
 sudo cp uclient ${VTE_TARGET_PRE2}/tools/
 #sudo cp uclient ${VTE_TARGET_PRE3}/tools/
 make clean
 cd $UCONFDIR
 make clean
 make CC=${TOOL_CHAIN}arm-none-linux-gnueabi-gcc PLATFORM=$1 || return 11
 #sudo cp u-config ${VTE_TARGET_PRE}/tools/
 #sudo cp printenv ${VTE_TARGET_PRE}/tools/
 #sudo cp setenv ${VTE_TARGET_PRE}/tools/
 sudo cp u-config ${VTE_TARGET_PRE2}/tools/
 sudo cp printenv ${VTE_TARGET_PRE2}/tools/
 sudo cp setenv ${VTE_TARGET_PRE2}/tools/
 #sudo cp u-config ${VTE_TARGET_PRE3}/tools/
 #sudo cp printenv ${VTE_TARGET_PRE3}/tools/
 #sudo cp setenv ${VTE_TARGET_PRE3}/tools/
 make clean
}

sync_server()
{
 cd $TOOLSDIR
 make clean
 make CC=gcc || return 10
 RETRY=3
 while [ $RETRY -gt 0 ]; do
  $TOOLSDIR/uclient ${CENTER_SERVER} 12500 ${1}_${2} && RETRY=0
  if [ $? -ne 0 ]; then
  	RETRY=$(expr $RETRY - 1)
  fi 
 done
}


branch_kernel()
{
if [ $all_one_branch = "n" ]; then
 if [ "$old_kernel_branch" = "$1" ]; then
	return 0
 fi
 old_kernel_branch=$1
 old_kernel_config=""
 cd $ROOTDIR
 if [ ! -e ${KERNEL_DIR} ]; then
 git clone git://sw-git.freescale.net/linux-2.6-imx.git
 fi
 cd ${KERNEL_DIR}
 git add . 
 git commit -s -m"reset"
 git reset --hard HEAD~1
 git checkout -b temp2 || git checkout temp2
 git branch -D temp
 git checkout -b temp  origin/$1
 git add . && git commit -s -m"reset" && git reset --hard HEAD~1 
 git remote update
 git branch -D build
 git fetch origin +$1:build && git checkout build || return 1
fi	
 return 0
}

branch_exa()
{
 if [ -z $1 ]; then
   return 0
 fi
 old_exa_branch=$1
 old_exa_config=""
 cd $ROOTDIR
 if [ ! -e ${EXA_DIR} ]; then
 git clone ssh://b20222@sw-git.freescale.net/git/sw_git/repos/linux-x-server-viv.git
 fi
 cd ${EXA_DIR}
 git add . 
 git commit -s -m"reset"
 git reset --hard HEAD~1
 git checkout -b temp2 || git checkout temp2
 git branch -D temp
 git checkout -b temp  origin/$1
 git add . && git commit -s -m"reset" && git reset --hard HEAD~1 
 git remote update
 git branch -D build
 git fetch origin +$1:build && git checkout build || return 1
 return 0
}

branch_gpu()
{
 if [ -z $1 ]; then
   return 0
 fi
 old_gpu_branch=$1
 old_gpu_config=""
 cd $ROOTDIR
 if [ ! -e ${GPU_DIR} ]; then
 git clone ssh://b20222@sw-git.freescale.net/git/sw_git/private/gpu-viv.git
 fi
 cd ${GPU_DIR}
 git add . 
 git commit -s -m"reset"
 git reset --hard HEAD~1
 git checkout -b temp2 || git checkout temp2
 git branch -D temp
 git checkout -b temp  origin/$1
 git add . && git commit -s -m"reset" && git reset --hard HEAD~1 
 git remote update
 git branch -D build
 git fetch origin +$1:build && git checkout build || return 1
 return 0
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

if [ $BUILD = "y" ]; then
 cd $ROOTDIR
 if [ ! -e ${UBOOT_DIR} ]; then
 git clone git://sw-git.freescale.net/uboot-imx.git
 fi
 cd ${UBOOT_DIR}
 git add . 
 git commit -s -m"reset"
 git reset --hard HEAD~1
 git checkout -b temp  origin/$UBOOT_BRH || git checkout temp
 git branch -D build
 git fetch origin +$UBOOT_BRH:build && git checkout build || exit -1

if [ $all_one_branch = "y" ]; then
 cd $ROOTDIR
 if [ ! -e ${KERNEL_DIR} ]; then
 git clone git://sw-git.freescale.net/linux-2.6-imx.git
 fi
 cd ${KERNEL_DIR}
 git add . 
 git commit -s -m"reset"
 git reset --hard HEAD~1
 git checkout -b temp  origin/$KERNEL_BRH || git checkout temp 
 git branch -D build
 git fetch origin +$KERNEL_BRH:build && git checkout build || exit -2
 cd $ROOTDIR
 if [ ! -e ${VTE_DIR} ]; then
 git clone git://shlx12.ap.freescale.net/vte
 fi
 cd $VTE_DIR
 git add . 
 git commit -s -m"reset"
 git reset --hard HEAD~1
 git checkout -b temp origin/$VTE_BRH || git checkout temp
 git branch -D build
 git fetch origin +$VTE_BRH:build && git checkout build || exit -3
fi
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

  cd $ROOTDIR
  if [ ! -e ${ROOTDIR}/linux-test ]; then
  git clone git://sw-git.freescale.net/linux-test
  fi
  cd $ROOTDIR/linux-test
  git add .
  git commit -s -m"reset"
  git reset --hard HEAD~1
  git checkout -b temp || git checkout temp
  git branch -D build
  git fetch origin +master:build && git checkout build || exit -5
fi 
#end if build

make_tools || exit -5

branch_libs
branch_atheros


for i in $PLATFORM;
do
  j=0
  sync_server ${i} NOREADY
  while [ $j -lt $SOC_CNT ];do
   c_plat=${plat_name[${j}]}
   deploy_target_rd=0
   deploy_vte_target_rd=0
   if [ "$c_plat" = $i ];then
     deploy_target_rd=${target_configs[${j}]}
     deploy_vte_target_rd=${vte_target_configs[${j}]}
     c_soc=${soc_name[${j}]}
     make_target_tools MX${c_soc} 
     make_uboot ${u_boot_configs[${j}]} $c_soc $c_plat "${rootfs_apd[${j}]}" || RC=$(echo $RC uboot_$i)
     branch_kernel ${kernel_branch[$j]}
     make_kernel ${kernel_configs[${j}]} $c_soc "${rootfs_apd[${j}]}" ${xrootfs[${j}]} || old_kernel_rc=$?
     if [ $old_kernel_rc -ne 0 ]; then 
	RC=$(echo $RC $i)
     fi
     branch_vte ${vte_branch[$j]}
     make_vte  ${vte_configs[${j}]} $c_soc "${rootfs_apd[${j}]}" ${test_plan[${j}]} $c_plat || old_vte_rc=$?
     if [ $old_vte_rc -ne 0 ]; then
     	RC=$(echo $RC vte_$i)
     fi
     update_rootfs $c_soc ${rootfs_apd[${j}]}
     make_libs ${linux_libs_branch[${j}]} ${linux_libs_platfm[${j}]} $c_soc "${rootfs_apd[${j}]}"
     make_unit_test ${unit_test_configs[${j}]} $c_soc "${rootfs_apd[${j}]}" || RC=$(echo $RC unit_test_$i) 
     branch_gpu  ${gpu_branch[$j]}
	 branch_exa  ${exa_branch[$j]}
     make_gpu  ${gpu_configs[${j}]} $c_soc "${rootfs_apd[${j}]}" || old_gpu_rc=$?
     make_gpu_x  ${gpu_configs[${j}]} $c_soc "${xrootfs[${j}]}" || old_gpu_rc=$?
	 make_exa ${gpu_configs[${j}]} $c_soc "${xrootfs[${j}]}" || old_gpu_rc=$?
     #if [ $old_kernel_rc -eq 0 ] && [ $old_vte_rc -eq 0 ] && [ $(echo $RC | grep uboot_$i | wc -l) -eq 0 ]
     #then
     	sync_server $i READY_KVER${KERNEL_VER}
     #fi
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

