#!/bin/bash
itime=$(date +%Y%m%d)
BASE=/home/ltib2/daily_build/linaro_nano 
ROOTFS=/mnt/nfs_root/imx53_rootfs_nano
WBASE=http://snapshots.linaro.org/11.05-daily/

#get the releae
#rm -rf ${BASE}/release
mkdir -p ${BASE}/release
cd ${BASE}/release
HWBASE=linaro-hwpacks/lt-mx5/${itime}/0/images/hwpack
HWPACK=hwpack_linaro-lt-mx5_${itime}-0_armel_supported.tar.gz

NANOBASE=linaro-nano/${itime}/0/images/tar
NANO=nano-n-tar-${itime}-0.tar.gz

wget ${WBASE}/${HWBASE}/${HWPACK} || exit 1
wget ${WBASE}/${NANOBASE}/${NANO} || exit 2

sudo cat << EOF > fstab
proc            /proc           proc    nodev,noexec,nosuid 0       0
#10.192.224.218:/rootfs/imx53_rootfs_nano   /   nfs  rw,noatime,nolock,vers=3 1 1
none       /tmp   tmpfs defaults 0 0
none       /var/run tmpfs defaults 0 0
none       /var/lock tmpfs defaults 0 0
none       /var/tmp  tmpfs defaults 0 0
#10.192.225.222:/rootfs/wb /mnt/nfs nfs rw,noatime,nolock,vers=3 1 1
#10.192.224.218:/rootfs /mnt/nfs_root nfs rw,noatime,nolock,vers=3 1 1
#10.192.225.226:/01_CodecVectors /mnt/stream nfs rw,noatime,nolock,vers=3 1 1
EOF

#untar the rootfs
sudo rm -rf $ROOTFS
sudo mkdir $ROOTFS
sudo tar xzvf ${NANO} -C $ROOTFS || exit 3

sudo cp -f fstab $ROOTFS/binary/etc/

sudo mkdir $ROOTFS/binary/etc/mnt/nfs
sudo mkdir $ROOTFS/binary/etc/mnt/nfs_root
sudo mkdir $ROOTFS/binary/etc/mnt/stream

#untart the hwpack
rm -rf hwpack
mkdir ${BASE}/hwpack
tar xzvf  $HWPACK -C ${BASE}/hwpack
cd ${BASE}/hwpack/pkgs/
uboot=$(ls *.deb)
for i in $uboot
do
sudo dpkg -x $i ${ROOTFS}/binary/
done

vmlinux=$(find ${ROOTFS}/binary/boot -name vmlinuz-*-linaro-lt-mx5)
sudo mkimage -A arm -O linux -T kernel -C none -a 0x70008000 -e 0x70008000 -n "Linaro Linux" -d ${vmlinux} ./uImage || exit 4

scp uImage root@10.192.225.218:/tftpboot/uImage_mx5_linaro

