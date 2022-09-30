#!/bin/bash


set -x

MAKE_PATH=/mnt/gentoo/etc/portage/make.conf
#A_L=ACCEPT_LICENSE="-* @FREE"

STAGE3_FILE=$(curl -s http://mirror.yandex.ru/gentoo-distfiles/releases/amd64/autobuilds)
STAGE3_URL=https://mirror.yandex.ru/gentoo-distfiles/releases/amd64/autobuilds



echo "make a time"
ntpd -q -g

password()
{
echo "Make a password for root"
passwd
}


partition()
{
			echo "disk markup"
			sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' <<- EOF | fdisk /dev/$DISK
			o # clear the in memory partition table
			n # new partition
			p # primary partition
			1 # partition number 1
			# default - start at beginning of disk
			+1GB
			n # new partition
			p # primary partition
			2 # partion number 2
			# default, start immediately after preceding partition
			# default, extend partition to end of disk
			a # make a partition bootable
			1 # bootable partition is partition 1 -- /dev/sda1
			p # print the in-memory partition table
			w # write the partition table
			q # and we're done
			EOF
	cd
}

answer()
{
cd
DISK=$1
	P_CHECK=$(lsblk -o NAME,FSTYPE -dSn | grep -o $DISK)
	if [ "$P_CHECK" == "$DISK" ] ; then
		echo "hahaha! This Disk and the Disk on that folder it is the same for you!"
		echo "still want to continue? (yes/no)"
		read ANSWER
		if [ "$ANSWER" == "yes"] ; then
		
		partition || DEBUGGER
		
		else if ["$ANSWER" == "y"] ; then
		
		partition || DEBUGGER
		
		else
			echo "goodbye" ; exit 0
		fi
		
}

fsys_maker() 
{
echo "making file system"

mkfs.vfat dev/sda1
mkfs.ext4 dev/sda2

mkdir /mnt/gentoo/boot
mount /dev/sda2 /mnt/gentoo
mount /dev/sda1 /mnt/gentoo/boot
}

stage3_maker()
{
cd
cd /mnt/gentoo
echo"unpack st3 archive"

wget $STAGE3_URL/$STAGE3_FILE
tar xpvf stage3-*.tar.bz2 --xattrs-include='*.*' --numeric-owner
}


DEBUGGER()
{
echo "Error: $1"
exit 1
}

password
fsys_maker || DEBUGGER
stage3_maker || DEBUGGER