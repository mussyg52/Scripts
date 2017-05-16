#!/bin/bash

sudo su
yum -y install parted
fdisk -l /dev/sdb
parted -s -a optimal /dev/sdb mklabel gpt
parted -s -a optimal /dev/sdb mkpart primary 0% 100%
pvcreate /dev/sdb1
vgcreate vgdata /dev/sdb1
lvcreate -L10230M -n lvdata vgdata
lvs
mkfs.ext4 /dev/vgdata/lvdata
mkdir /opt/openbet
echo "/dev/mapper/vgdata-lvdata                  /opt/openbet     ext4    rw,nodev                0  0"  >> /etc/fstab
mount /opt/openbet
tar -xvf openbetfiles.tar
cd openbetconfig
chmod +x *.sh
./openbet_rgarforth.sh
./openbet_all.sh
