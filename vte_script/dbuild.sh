#!/bin/bash -x

#PLATFORM="233 25 28 31 35 37 25 50 51 53"
PLATFORM="50 53"
BUILD=y
KERNEL_BRH=imx_2.6.35
UBOOT_BRH=imx_v2009.08
#PLATFORM="5x"
VTE_TARGET_PRE=/mnt/vte/
TARGET_ROOTFS=/mnt/nfs_root/
ROOTDIR=/home/ltib2/daily_build/
KERNEL_DIR=${ROOTDIR}/linux-2.6-imx/
UBOOT_DIR=${ROOTDIR}/uboot-imx
VTE_DIR=${ROOTDIR}/vte
TOOLSDIR=${ROOTDIR}/skywalker/udp_sync

export PATH=$PATH:/opt/freescale/usr/local/gcc-4.4.4-glibc-2.11.1-multilib-1.0/arm-fsl-linux-gnueabi/bin

RC=0

#below is the matrix for rootfs
declare -a soc_name;
declare -a u_boot_configs;
declare -a kernel_configs;
declare -a vte_configs;
# As bash only support 1 dimension array below sequence is our assumption
# 0   1  2  3  4  5  6  7  8   
#(23 25 28 31 35 37 50 51 53)
#SOC names
#           0     1    2    3    4   5    6    7    8
soc_name=("233" "25" "28" "31" "35" "37" "50" "51" "53");
SOC_CNT=9
#default u-boot kernel configs for each platform
u_boot_configs=("mx23_evk_config" "mx25_3stack_config" "mx28_evk_config" "mx31_3stack_config" "mx35_3stack_config" "mx31_3stack_config" "mx50_rdp_config" "mx51_bbg_config" "mx53_smd_config")
#default kernel configs for each platform
kernel_configs=("imx23evk_defconfig" "imx25_3stack_defconfig" "imx28evk_defconfig" "mx3_defconfig" "mx35_3stack_config" "mx3_defconfig" \
                "imx5_defconfig" "imx5_defconfig" "imx5_defconfig");
#vte configs
vte_configs=("mx233_armadillo_config" "mx25_3stack_config" "mx28_evk_config" "mx31_3stack_config" "mx35_3stack_config" "mx37_3stack_config" \
             "mx5x_evk_config" "mx5x_evk_config" "mx5x_evk_config");

make_uboot()
{
echo "make uboot $2 with $1"
cd $UBOOT_DIR
make ARCH=arm CROSS_COMPILE=arm-none-linux-gnueabi- distclean
make ARCH=arm CROSS_COMPILE=arm-none-linux-gnueabi- $1 || return 1
make ARCH=arm CROSS_COMPILE=arm-none-linux-gnueabi- || return 2
scp u-boot.bin root@10.192.225.218:/tftpboot/u-boot-mx${2}_d.bin || return 3
scp u-boot.bin root@10.192.225.218:/var/ftp/u-boot-mx${2}_d.bin || return 3
return 0
}

make_kernel()
{
echo "make Platform $2 with $1"
cd $KERNEL_DIR
if [ "$old_kernel_config" = $1 ];then
if [ "$old_kernel_rc" -eq 0 ]; then
rm -rf ${TARGET_ROOTFS}/imx${2}_rootfs/lib/modules/*-daily
sudo make ARCH=arm modules_install INSTALL_MOD_PATH=${TARGET_ROOTFS}/imx${2}_rootfs || return 3
scp arch/arm/boot/uImage root@10.192.225.218:/tftpboot/uImage_mx${2}_d
scp arch/arm/boot/uImage root@10.192.225.218:/var/ftp/uImage_mx${2}_d
fi
return $old_kenel_rc
fi
old_kernel_config=$1
make distclean
lv=$(git log | head -n 1 | cut -d " " -f 2 | cut -c 1-8)
echo "-g${lv}-daily"  > localversion
make ARCH=arm CROSS_COMPILE=arm-none-linux-gnueabi- $1 || return 1
make ARCH=arm CROSS_COMPILE=arm-none-linux-gnueabi- -j 2 uImage|| return 2
rm -rf ${TARGET_ROOTFS}/imx${2}_rootfs/lib/modules/*-daily
make ARCH=arm CROSS_COMPILE=arm-none-linux-gnueabi- -j 2 modules|| return 4
sudo make ARCH=arm modules_install INSTALL_MOD_PATH=${TARGET_ROOTFS}/imx${2}_rootfs || return 3
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
 if [ $old_vte_rc -eq 0 ]; then
   sudo cp -a bin/* ${VTE_TARGET_PRE}/vte_mx${2}/bin/
   sudo cp -a testcases/bin/* ${VTE_TARGET_PRE}/vte_mx${2}_d/testcases/bin/
 fi
return $old_vte_rc
fi
old_vte_config=$1
make distclean
source  $1
./armconfig
make vte || return 1
make apps || ret=1
#make ltp tests
if [ $BUILD = "y" ]; then
make
sudo cp -a bin/* ${VTE_TARGET_PRE}/vte_mx${2}/bin/
#sudo scp -r bin/* b17931@survivor:/rootfs/wb/vte_mx${2}_d/bin
fi
sudo cp -a testcases/bin/* ${VTE_TARGET_PRE}/vte_mx${2}_d/testcases/bin/
#sudo scp -r testcases/bin/* b17931@survivor:/rootfs/wb/vte_mx${2}_d/testcases/bin
old_vte_rc=0
return $ret
}

make_tools()
{
 cd $TOOLSDIR
 CROSS_COMPILER="" make
}

sync_server()
{
 $TOOLSDIR/uclient 10.192.225.222 12500 ${1}_${2} 
}

#main

old_kernel_config=
old_kernel_rc=0
old_vte_config=
old_vte_rc=0

if [ $BUILD = "y" ]; then

 cd $ROOTDIR
 if [ ! -e ${UBOOT_DIR} ]; then
 git clone git://sw-git01-tx30/uboot-imx.git
 fi
 cd ${UBOOT_DIR}
 git checkout -b temp || git checkout temp
 git branch -D build
 git fetch origin +$UBOOT_BRH:build && git checkout build || exit -1

 cd $ROOTDIR
 if [ ! -e ${KERNEL_DIR} ]; then
 git clone git://sw-git01-tx30.am.freescale.net/linux-2.6-imx.git
 fi
 cd ${KERNEL_DIR}
 git checkout -b temp || git checkout temp
 git branch -D build
 git fetch origin +$KERNEL_BRH:build && git checkout build || exit -2

 cd $ROOTDIR
 if [ ! -e ${VTE_DIR} ]; then
 git clone git://shlx12.ap.freescale.net/vte
 fi
 cd $VTE_DIR
  git checkout -b temp || git checkout temp
  git branch -D build
 git fetch origin +master:build && git checkout build || exit -3

 cd $ROOTDIR
 if [ ! -e $ROOTDIR/skywalker ]; then
  git clone git://10.192.225.222/skywalker
  fi
  cd $ROOTDIR/skywalker
  git checkout -b temp || git checkout tmp
  git branch -D build
  git fetch origin +master:build && git checkout build
fi 
#end if build

make_tools

for i in $PLATFORM;
do
  j=0
	sync_server $i NOREADY
  while [ $j -lt $SOC_CNT ];do
   c_soc=${soc_name[${j}]}
   if [ "$c_soc" = $i ];then
     make_uboot ${u_boot_configs[${j}]} $c_soc || RC=$(echo $RC uboot_$i)
     make_kernel ${kernel_configs[${j}]} $c_soc || old_kernel_rc=$?
     if [ $old_kernel_rc -ne 0 ]; then 
	RC=$(echo $RC $i)
     fi
     make_vte  ${vte_configs[${j}]} $c_soc || old_vte_rc=$?
     if [ $old_vte_rc -ne 0 ]; then
     	RC=$(echo $RC vte_$i)
     fi
     sync_server $i READY_KVER$(cat $KERNEL_DIR/localversion)
   fi
   j=$(expr $j + 1)
  done
done

echo $RC
if [ "$RC" = "0" ]; then
echo "VTE daily build with $RC" | mutt -s "VTE daily build OK" \
b20222@shlx12.ap.freescale.net 
echo build success!!
else
echo "VTE daily build with $RC" | mutt -s "VTE daily build Fail" \
b20222@shlx12.ap.freescale.net
echo build Fail $RC!
fi

