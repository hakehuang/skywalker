#!/bin/bash -x
#pre-requisities:
#a test board reachable nfs is mounted at /mnt/nfs/

TARGET_ROOTFS_BASE="/mnt/nfs_root/"
TARGET_APP_BASE="/mnt/vte/util/"
BUILD=y
TOOLS_PATH=/home/ltibs/tools
ROOTDIR=$(pwd)
GIT_SERVER=10.192.225.222/Graphics

sudo ntpdate 10.19.225.222
#export PATH=$PATH:/opt/freescale/usr/local/gcc-4.4.4-glibc-2.11.1-multilib-1.0/arm-fsl-linux-gnueabi/bin
export CROSS_COMPILE=arm-none-linux-gnueabi-

RC=0

platfm_rootfs="imx50_rootfs imx53_rootfs ubuntu_10.04 imx61_rootfs"
declare -a platfm_rootfs_config;
declare -a platfm_cflags;
#rootfs can only has FB or XGL, otherwise will be taken as XGL
platfm_rootfs_config=("FB" "FB" "XGL" "FB");
#CFLAGS for different rootfs
platfm_cflags=("-Wall -O2 -fsigned-char -march=armv7-a -mfpu=neon -mfloat-abi=softfp " \
"-Wall -O2 -fsigned-char -march=armv7-a -mfpu=neon -mfloat-abi=softfp ")

#below is the matrix for gpu applications
declare -a apps;
declare -a apps_configs_FB;
declare -a apps_configs_XGL;
declare -a apps_dir_FB;
declare -a apps_dir_XGL;
apps_cnt=4
apps=("3DMarkMobile.git" "bbPinball.git" "openGLES.git" "openVG.git");
apps_support=("imx53_rootfs ubuntu_10.04 imx61_rootfs" "imx53_rootfs ubuntu_10.04" \
"imx53_rootfs ubuntu_10.04" "imx50_rootfs imx53_rootfs ubuntu_10.04");
apps_configs_FB=("fsl_imx_linux" "master" "FB" "framebuffer_crosscompile");
apps_configs_XGL=("fsl_egl_x" "xwindow" "master" "egl_x_crosscompile");
apps_dir_FB=("configuration/fsl_imx_linux" "mak" "." ".");
apps_dir_XGL=("configuration/iMX51_pdk" "mak" "." ".");


iplat_cnt=0


mkdir -p ${TARGET_APP_BASE}Graphics/
#sudo rm -rf ${TARGET_APP_BASE}Graphics/
#sudo chmod -R 777 ${TARGET_APP_BASE}Graphics/


for k in $platfm_rootfs
do
  TARGET_ROOTFS=${TARGET_ROOTFS_BASE}/$k
	export CFLAGS=${platfm_cflags[${iplat_cnt}]}
  icnt=0
  if [ $BUILD = 'y' ]; then
    while [ $icnt -lt $apps_cnt ]; do
      CUR_CONFIG=${platfm_rootfs_config[${iplat_cnt}]}
      cd $ROOTDIR
      apps_name=${apps[${icnt}]}
      support_fs=${apps_support[${icnt}]}
      is_support=$(echo $support_fs | grep $k| wc -l)
      if [ $is_support -eq 0 ]; then
      	icnt=$(expr $icnt + 1)
         continue;
      fi
      if [ $CUR_CONFIG = "FB" ];then
      apps_config=${apps_configs_FB[${icnt}]}
      else
      apps_config=${apps_configs_XGL[${icnt}]}
      fi
      cdir=$(echo $apps_name | cut -d"." -f 1) 
      if [ ! -e $cdir ]; then
       git clone git://${GIT_SERVER}/$apps_name
      fi
      cd $cdir
      git checkout -b temp || git checkout temp
      if [ $? -ne 0 ]; then
       git add .
       git commit -s -m"reset"
       git reset --hard HEAD~1
       git checkout -b temp || git checkout temp
      fi
      make clean
      git branch -D build_${apps_config}_$k
      git fetch origin +${apps_config}:build_${apps_config}_$k && git checkout build_${apps_config}_$k || exit -3
			if [ $CUR_CONFIG = "FB" ];then
      	cd ${apps_dir_FB[${icnt}]}
			else
      	cd ${apps_dir_XGL[${icnt}]}
      fi
      make ROOTFS=${TARGET_ROOTFS} || RC=($RC ${cdir}_${apps_config}_$k)
      #make clean
      #cd $ROOTDIR/$cdir
      #git add .
			#cmts=$(date +%y%m%d)
      #git commit -s -m"make result $cmts"
      icnt=$(expr $icnt + 1)
      cd ${ROOTDIR}
      sudo mkdir ${TARGET_APP_BASE}Graphics/$k
      if [ $cdir = "openVG" ]; then
      sudo tar czvf ${cdir}.tar.gz ${cdir}/cts_1.0.1/generation/make/linux/bin/generator.exe \
      ${cdir}/cts_1.1/generation/make/linux/bin/generator.exe \
      ${cdir}/VGMark_10_src 
      else
       sudo tar czvf ${cdir}.tar.gz --exclude-tag-all=FETCH_HEAD  ${cdir}
      fi
      sudo mv ${cdir}.tar.gz  ${TARGET_APP_BASE}Graphics/$k/
    done
  fi
  iplat_cnt=$(expr $iplat_cnt + 1)
done

echo $RC
if [ "$RC" = "0" ]; then
echo "gpu apps build ok" | mutt -s "gpu build OK" \
b20222@shlx12.ap.freescale.net
echo Happy123 | ssh b20222@10.192.225.222 'sudo /rootfs/wb/util/Graphics/untar.sh' 
else
echo "gpu apps build fail" | mutt -s "gpu build fail" \
b20222@shlx12.ap.freescale.net 
fi
