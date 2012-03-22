#!/bin/bash -x

#PLATFORM="233 25 28 31 35 37 25 50 51 53"
PLATFORM="IMX50RDP IMX50-RDP3 IMX53LOCO IMX51-BABBAGE IMX53SMD IMX6-SABREAUTO IMX6-SABRELITE IMX6ARM2 IMX6DL-ARM2 IMX6Solo-SABREAUTO"
BUILD=y
#kernel branch and vte branch need define all one branch
KERNEL_BRH=imx_2.6.35
#KERNEL_BRH=imx_2.6.38
VTE_BRH=imx2.6.35.3
UBOOT_BRH=imx_v2009.08
#PLATFORM="5x"
VTE_TARGET_PRE=/mnt/vte/
VTE_TARGET_PRE2=/mnt/nfs/
TARGET_ROOTFS=/mnt/nfs_root/
ROOTDIR=/home/ltib2/daily_build/
KERNEL_DIR=${ROOTDIR}/linux-2.6-imx/
UBOOT_DIR=${ROOTDIR}/uboot-imx
VTE_DIR=${ROOTDIR}/vte
TOOLSDIR=${ROOTDIR}/skywalker/udp_sync
UCONFDIR=${ROOTDIR}/skywalker/uboot-env
SCRPTSDIR=${ROOTDIR}/skywalker/vte_script
UNITTEST_DIR=${ROOTDIR}/linux-test
FIRMWARE_DIR=${ROOTDIR}/linux-firmware-imx
LIB_DIR=${ROOTDIR}/linux-lib

all_one_branch=n

export PATH=$PATH:/opt/freescale/usr/local/gcc-4.4.4-glibc-2.11.1-multilib-1.0/arm-fsl-linux-gnueabi/bin

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
# As bash only support 1 dimension array below sequence is our assumption
# 0   1  2  3  4  5  6  7  8  9  10 11
#(23 25 28 31 35 37 50 50  51 53 53 61)
#SOC names
#           0     1    2    3    4   5    6    7    8   9 10
kernel_branch=("imx_2.6.35" "imx_2.6.35" "imx_2.6.35" "imx_2.6.35" "imx_2.6.35" "imx_2.6.35" \
"imx_2.6.35" "imx_2.6.35" "imx_2.6.35" "imx_2.6.35" "imx_2.6.35" "imx_3.0.15" "imx_3.0.15" "imx_3.0.15" "imx_3.0.15" "imx_3.0.15");
vte_branch=("imx2.6.35.3" "imx2.6.35.3" "imx2.6.35.3" "imx2.6.35.3" "imx2.6.35.3" "imx2.6.35.3" \
"imx2.6.35.3" "imx2.6.35.3" "imx2.6.35.3" "imx2.6.35.3" "imx2.6.35.3" "master" "master" "master" "master" "master");
plat_name=("IMX23EVK" "IMX25-3STACK" "IMX28EVK" "IMX31-3STACK" "IMX35-3STACK" \
"IMX37-3STACK" "IMX50RDP" "IMX50-RDP3"  "IMX51-BABBAGE" "IMX53SMD" "IMX53LOCO" \
"IMX6-SABREAUTO" "IMX6-SABRELITE" "IMX6ARM2" "IMX6DL-ARM2" "IMX6Solo-SABREAUTO");
soc_name=("233" "25" "28" "31" "35" "37" "50"  "50" "51" "53" "53" "63" "63" "63" "61" "61");
SOC_CNT=16
#default u-boot kernel configs for each platform
u_boot_configs=("mx23_evk_config" "mx25_3stack_config" "mx28_evk_config" \
"mx31_3stack_config" "mx35_3stack_config" "mx31_3stack_config" \
"mx50_rdp_config" "mx50_rd3_config"  "mx51_bbg_config" "mx53_smd_config" "mx53_loco_config" \
"mx6q_sabreauto_config" "mx6q_sabrelite_config" "mx6q_arm2_config" "mx6dl_arm2_config" "mx6solo_sabreauto_config");
#default kernel configs for each platform
kernel_configs=("imx23evk_defconfig" "imx25_3stack_defconfig" \
"imx28evk_defconfig" "mx3_defconfig" "mx35_3stack_config" "mx3_defconfig" \
"imx5_defconfig" "imx5_defconfig" "imx5_defconfig" "imx5_defconfig" "imx5_defconfig" \
"imx6_defconfig" "imx6_defconfig" "imx6_defconfig" "imx6_defconfig" "imx6_defconfig");
#vte configs
vte_configs=("mx233_armadillo_config" "mx25_3stack_config" "mx28_evk_config" \
"mx31_3stack_config" "mx35_3stack_config" "mx37_3stack_config" \
"mx5x_evk_config" "mx5x_evk_config" "mx5x_evk_config" "mx5x_evk_config" \
"mx5x_evk_config" "mx6x_evk_config" "mx6x_evk_config" "mx6x_evk_config" "mx6x_evk_config" "mx6x_evk_config");
#unit_test_configs
unit_test_configs=("IMX233" "IMX25" "IMX28" "IMX3" "IMX3" "IMX3" "IMX5" \
"IMX5" "IMX5" "IMX51" "IMX53" "IMX6" "IMX6" "IMX6" "IMX6" "IMX6");
#linux_libs_platfm
linux_libs_platfm=("NULL" "NULL" "NULL" "NULL" "NULL" "IMX37_3STACK" "NULL" "NULL" "IMX51" "IMX53" "IMX53" "IMX6Q" "IMX6Q" "IMX6Q" "IMX6Q" "IMX6Q");
linux_libs_branch=("master" "master" "master" "master" "master" "master" "master" \
"master" "master" "master" "master" "master" "master" "master" "master" "master");

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
  make PLATFORM=${2} CROSS_COMPILE=arm-none-linux-gnueabi- INCLUDE="-I${KERNEL_DIR}/include -I${KERNEL_DIR}/drivers/mxc/security/rng/include -I${KERNEL_DIR}/drivers/mxc/security/sahara2/include" -k || iRC=1
  sudo make DEST_DIR=${TARGET_ROOTFS}/imx${3}_rootfs install -k || iRC=$(expr $iRC + 1)
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
    sudo rm -rf ${TARGET_ROOTFS}/imx${1}_rootfs/lib/firmware
    sudo cp -af ${FIRMWARE_DIR}/firmware ${TARGET_ROOTFS}/imx${1}_rootfs/lib/ || return 1
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
  if [ -z $platform ];then
    echo $LINE >> unit_test
  fi
 done < all-suite.txt

 sed -i 's/:/\t/g' unit_test
 ucs=$(cat unit_test | grep -i FSL-UT | wc -l)
 if [ $ucs -ne 4 ];then
    echo "VTE daily build found unit test change" | mutt -s "the unit test count is $ucs changed" \
		b20222@freescale.com 
 fi
 sudo cp unit_test ${VTE_TARGET_PRE}/vte_mx${2}_d/runtest/
 sudo cp unit_test ${VTE_TARGET_PRE2}/vte_mx${2}_d/runtest/
 old_ut_plat=$2
 old_ut_rc=0
 PLATFORM=$1
 KERNELDIR=$KERNEL_DIR
 KBUILD_OUTPUT=$KERNEL_DIR
 INCLUDE="-I${TARGET_ROOTFS}/imx${2}_rootfs/usr/include \
 -I${TARGET_ROOTFS}/imx${2}_rootfs/usr/src/linux/include \
 -I./include/"
 LIB="-L/mnt/nfs_root/imx${2}_rootfs/usr/lib"
 make distclean
 make -C module_test KBUILD_OUTPUT=$KBUILD_OUTPUT LINUXPATH=$KERNELDIR  CC=arm-none-linux-gnueabi-gcc \
 CROSS_COMPILE=arm-none-linux-gnueabi- || old_ut_rc=1
 make -j1 PLATFORM=$PLATFORM INC="${INCLUDE}" LIBS=${LIB} test  CC=arm-none-linux-gnueabi-gcc \
 CROSS_COMPILE=arm-none-linux-gnueabi- || old_ut_rc=$(expr $old_ut_rc + 2)
 sudo make -C module_test -j1 LINUXPATH=$KERNELDIR KBUILD_OUTPUT=$KBUILD_OUTPUT \
 CROSS_COMPILE=arm-none-linux-gnueabi- \
 DEPMOD=/bin/true INSTALL_MOD_PATH=${TARGET_ROOTFS}/imx${2}_rootfs install -k || old_ut_rc=$(expr $old_ut_rc + 4)
 sudo  make PLATFORM=$PLATFORM DESTDIR=${TARGET_ROOTFS}/imx${2}_rootfs/unit_tests \
 CROSS_COMPILE=arm-none-linux-gnueabi- install || old_ut_rc=$(expr $old_ut_rc + 8)
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
#rm -f ${1}_config.txt
sudo cp u-boot-${1}-config.bin /mnt/nfs_root/imx${3}_rootfs/root/u-boot-${1}-config.bin || return 3
rm -rf  u-boot-${1}-config.bin
}

make_uboot()
{
echo "make uboot $2 with $1"
cd $UBOOT_DIR
make ARCH=arm CROSS_COMPILE=arm-none-linux-gnueabi- distclean
make ARCH=arm CROSS_COMPILE=arm-none-linux-gnueabi- $1 || return 1
make ARCH=arm CROSS_COMPILE=arm-none-linux-gnueabi- || return 2
scp u-boot.bin root@10.192.225.218:/tftpboot/u-boot-${3}_d.bin
scp u-boot.bin root@10.192.225.218:/var/ftp/u-boot-${3}_d.bin
scp u-boot.bin ubuntu@10.192.244.7:/var/lib/tftpboot/u-boot-${3}_d.bin
sudo cp u-boot.bin /mnt/nfs_root/imx${2}_rootfs/root/u-boot-${3}_d.bin || return 3
make_uboot_config $3 $(git log | head -1 | cut -d " " -f 2 | cut -c 1-6) $2 || return 3 
return 0
}

make_kernel()
{
echo "make Platform $2 with $1"
cd $KERNEL_DIR
if [ "$old_kernel_config" = $1 ];then
if [ "$old_kernel_rc" -eq 0 ]; then
#sudo rm -rf ${TARGET_ROOTFS}/imx${2}_rootfs/lib/modules/*-daily*
sudo make ARCH=arm modules_install INSTALL_MOD_PATH=${TARGET_ROOTFS}/imx${2}_rootfs || return 3
scp arch/arm/boot/uImage root@10.192.225.218:/tftpboot/uImage_mx${2}_d
scp arch/arm/boot/uImage root@10.192.225.218:/var/ftp/uImage_mx${2}_d
scp arch/arm/boot/uImage ubuntu@10.192.244.7:/var/lib/tftpboot/uImage_mx${2}_d
fi
return $old_kernel_rc
fi
old_kernel_config=$1
git branch -D build_${2}
git checkout build || git add . && git commit -s -m"build $(date +%m%d)" && git checkout build
git checkout -b build_${2} build
make distclean
echo "-daily"  > localversion
make ARCH=arm CROSS_COMPILE=arm-none-linux-gnueabi- $1 || return 1
make ARCH=arm CROSS_COMPILE=arm-none-linux-gnueabi- -j 2 uImage|| return 2
KERNEL_VER=$(./scripts/setlocalversion)
sudo rm -rf ${TARGET_ROOTFS}/imx${2}_rootfs/lib/modules/*-daily*
make ARCH=arm CROSS_COMPILE=arm-none-linux-gnueabi- -j 2 modules|| return 4
sudo make ARCH=arm modules_install INSTALL_MOD_PATH=${TARGET_ROOTFS}/imx${2}_rootfs || return 3
sudo make ARCH=arm headers_install INSTALL_HDR_PATH=${TARGET_ROOTFS}/imx${2}_rootfs/usr/src/linux/ || return 5
scp arch/arm/boot/uImage root@10.192.225.218:/tftpboot/uImage_mx${2}_d
scp arch/arm/boot/uImage root@10.192.225.218:/var/ftp/uImage_mx${2}_d
old_kernel_rc=0
return 0
}

make_vte()
{
ret=0
cd $VTE_DIR
if [ "$old_vte_config" = $1 ]; then
 if [ $old_vte_rc -eq 0 ] && [ -e $VTE_DIR/install ]; then
   sudo cp -a install/* ${VTE_TARGET_PRE}/vte_mx${2}_d/
   sudo cp -a testcases/bin/* ${VTE_TARGET_PRE}/vte_mx${2}_d/testcases/bin/
   sudo cp mytest ${VTE_TARGET_PRE}/vte_mx${2}_d/
   sudo cp -a install/* ${VTE_TARGET_PRE2}/vte_mx${2}_d/
   sudo cp -a testcases/bin/* ${VTE_TARGET_PRE2}/vte_mx${2}_d/testcases/bin/
   sudo cp mytest ${VTE_TARGET_PRE2}/vte_mx${2}_d/
 fi
return $old_vte_rc
fi
old_vte_config=$1
make distclean
sudo rm -rf install
source $1
export KLINUX_SRCDIR=${TARGET_ROOTFS}/imx${2}_rootfs/usr/src/linux/
export KERNEL_SRCDIR=${KERNEL_DIR}
export KLINUX_BLTDIR=${KERNEL_DIR}
export CROSS_COMPILE=arm-none-linux-gnueabi-
export CC=${CROSS_COMPILE}gcc
autoreconf -f -i -Wall,no-obsolete
aclocal -I m4
autoconf
automake -a
make autotools
./configure --host=arm-none-linux-gnueabi --prefix=$(pwd)/install CC=${CROSS_COMPILE}gcc
make
make vte || exit 1
make apps || ret=2
make install
#make ltp tests
#if [ $BUILD = "y" ]; then
#sudo scp -r bin/* b17931@survivor:/rootfs/wb/vte_mx${2}_d/bin
#fi
sudo cp -a install/* ${VTE_TARGET_PRE}/vte_mx${2}_d/
sudo cp -a testcases/bin/* ${VTE_TARGET_PRE}/vte_mx${2}_d/testcases/bin/
sudo cp mytest ${VTE_TARGET_PRE}/vte_mx${2}_d/
sudo cp -a install/* ${VTE_TARGET_PRE2}/vte_mx${2}_d/
sudo cp -a testcases/bin/* ${VTE_TARGET_PRE2}/vte_mx${2}_d/testcases/bin/
sudo cp mytest ${VTE_TARGET_PRE2}/vte_mx${2}_d/
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
 sudo cp vte ${TARGET_ROOTFS}/imx${1}_rootfs/etc/rc.d/init.d/vte 	
 deploy_firmware $1
}

make_target_tools()
{
 cd $TOOLSDIR
 make clean
 CROSS_COMPILER=arm-none-linux-gnueabi- make || return 10
 sudo cp uclient ${VTE_TARGET_PRE}/tools/
 sudo cp uclient ${VTE_TARGET_PRE2}/tools/
 make clean
 cd $UCONFDIR
 make clean
 make CC=arm-none-linux-gnueabi-gcc PLATFORM=$1 || return 11
 sudo cp u-config ${VTE_TARGET_PRE}/tools/
 sudo cp printenv ${VTE_TARGET_PRE}/tools/
 sudo cp setenv ${VTE_TARGET_PRE}/tools/
 sudo cp u-config ${VTE_TARGET_PRE2}/tools/
 sudo cp printenv ${VTE_TARGET_PRE2}/tools/
 sudo cp setenv ${VTE_TARGET_PRE2}/tools/
 make clean
}

sync_server()
{
 cd $TOOLSDIR
 make clean
 make CC=gcc || return 10
 $TOOLSDIR/uclient 10.192.225.222 12500 ${1}_${2} 
 $TOOLSDIR/uclient 10.192.244.61 12500 ${1}_${2} 
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
 git clone git://sw-git01-tx30/uboot-imx.git
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

for i in $PLATFORM;
do
  j=0
	sync_server $i NOREADY
  while [ $j -lt $SOC_CNT ];do
   c_plat=${plat_name[${j}]}
   if [ "$c_plat" = $i ];then
     c_soc=${soc_name[${j}]}
     make_target_tools MX${c_soc} 
     make_uboot ${u_boot_configs[${j}]} $c_soc $c_plat || RC=$(echo $RC uboot_$i)
     branch_kernel ${kernel_branch[$j]}
     make_kernel ${kernel_configs[${j}]} $c_soc || old_kernel_rc=$?
     if [ $old_kernel_rc -ne 0 ]; then 
				RC=$(echo $RC $i)
     fi
	 branch_vte ${vte_branch[$j]}
     make_vte  ${vte_configs[${j}]} $c_soc || old_vte_rc=$?
     if [ $old_vte_rc -ne 0 ]; then
     	RC=$(echo $RC vte_$i)
     fi
     update_rootfs $c_soc
     make_libs ${linux_libs_branch[${j}]} ${linux_libs_platfm[${j}]} $c_soc
     make_unit_test ${unit_test_configs[${j}]} $c_soc || RC=$(echo $RC unit_test_$i) 
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
echo "VTE daily build with $RC" | mutt -s "VTE daily build OK" \
b20222@freescale.com 
echo build success!!
else
echo "VTE daily build with $RC" | mutt -s "VTE daily build Fail" \
b20222@freescale.com
echo build Fail $RC!
fi

