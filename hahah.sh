#!/bin/bash


set -x

MAKE_PATH=/mnt/gentoo/etc/portage/make.conf

STAGE_FILE3=$(curl -s http://mirror.yandex.ru/gentoo-distfiles/releases/amd64/autobuilds)
STAGE3_URL=https://mirror.yandex.ru/gentoo-distfiles/releases/amd64/autobuilds

echo "установка времени"
ntpd -q -g

password()
{
echo "придумайте пароль root-а"
passwd
}


partition()
{
cd
parted -a optimal /dev/sda
mklabel gpt
unit GB
mkpart primary 1 2
name 1 grub
set 1 bios_grub on
mkpart primary 2 3
name 2 boot
mkpart primary 3 4
name 3 swap
mkpart primary 4 -1
name 4 rootfs
quit
}



password
partition
