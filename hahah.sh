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
echo " wanna Make a password for root?"
read RESPONS
	if [ "$RESPONS" == "yes" ] ; then
		passwd
	else
		echo "goodbye"
	fi


}


partition()
{
cd
DISK=$1
	P_CHECK=$(lsblk -o NAME,FSTYPE -dSn | grep -o $DISK)
	if [ "$P_CHECK" == "$DISK" ] ; then
		echo "Your Disk and the Disk on that folder it is the same thing"
		echo "still want to continue? (yes/no)"
		read ANSWER
		if [ "$ANSWER" == "yes" ] ; then
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
		else
			echo "goodbye"
		fi
	fi
	cd
}

fsys_maker() 
{
	echo "making file system"

	mkfs.vfat -F 32 /dev/sda1
	mkfs.ext4 /dev/sda2
	mkdir /mnt/gentoo/boot
	mount /dev/sda2 /mnt/gentoo
	mount /dev/sda1 /mnt/gentoo/boot
	
}

stage3_maker()
{
cd
echo"unpack st3 archive"
cd /mnt/gentoo

wget $STAGE3_URL/$STAGE3_FILE
tar xpvf ${STAGE3_FILE:17}
}


debugger()
{
echo "Error: $1"
exit 1
}

password || debugger "password error"
echo "target your disk for partition"
read DISK
partition $DISK || debugger "DISK partition error"
fsys_maker || debugger "file system making error"
stage3_maker || debugger "stage3 installation error"