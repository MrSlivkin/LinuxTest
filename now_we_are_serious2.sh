#!/bin/bash

portage_installation()
{
	
	echo "ebuild gentoo files installation"

	emerge-websync
	emerge --sync

}

profile_selection()
{

echo "choose the profile"
eselect profile list
read NUMBER
eselect profile set "$NUMBER"

}

world_update(){

	echo "update @world "
	emerge --ask --verbose --update --deep --newuse @world

	echo "make a timezone Yekaterinburg like"
	echo "USE='minimal -pasystemd  X gtk gnome -qt5 -kde dvd alsa cdr'" >> $MAKE_PATH
	echo "ACCEPT_LICENSE='*'" >> $MAKE_PATH
	echo "Asia/Yekaterinburg" > /etc/timezone

	emerge --config sys-libs/timezone-data

}

locale_update()
{
	
	echo "make main local language russian"
	echo "en_US ISO-8859-1" >> $LOCALE_PATH
	echo "en_US.UTF-8 UTF-8" >> $LOCALE_PATH
	echo "ru_RU.UTF-8 UTF-8" >> $LOCALE_PATH

	locale-gen

	echo "LANG='ru_RU.UTF-8'" >$LOCALE02
	echo "LC_COLLATE='C.UTF-8'" >>$LOCALE02

	emerge --ask sys-kernel/gentoo-sources
	env-update && source /etc/profile && export PS1="(chroot) $PS1"

}

	debugger()
	{
	echo "Error: $1"
	exit 1
	}
	
	
portage_installation || debugger "install error"
profile_selection || debugger"making profile error"
world_update || debugger"update @world error"