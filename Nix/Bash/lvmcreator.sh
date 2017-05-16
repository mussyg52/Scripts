#!/bin/bash

#Vars

DISK=sdb
LABEL=gpt
VGNAME=vgdata
LVNAME=lvdata
LVSIZE=10230M
FSTYPE=ext4


yum -y install parted
parted -s -a optimal /dev/$DISK mklabel $LABEL &&
parted -s -a optimal /dev/$DISK mkpart primary 0% 100% &&
pvcreate /dev/"$DISK"1 &&
vgcreate $VGNAME /dev/"$DISK"1 &&
lvcreate -L$LVSIZE -n $LVNAME $VGNAME &&
mkfs.$FSTYPE /dev/$VGNAME/$LVNAME

exit 0
