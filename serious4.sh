#!/bin/bash

MAKE_PATH=/etc/portage/make.conf


driver_install(){

	echo "drivers update installation"
	echo "creating new user:"
	read NAME

	useradd -m -G wheel,audio,video $NAME
	echo "wanna change or create $NAME password?"
	read RESPONS
	if [ "$RESPONS" == "yes" ] ; then
		passwd $NAME
	else
		echo "ok, bye"
	fi

	echo "VIDEO_CARDS='amdgpu radeon radensi'" >>$MAKE_PATH
	echo "INPUT_DEVICES='synaptics libinput'" >>$MAKE_PATH

	emerge --pretend --verbose x11-base/xorg-drivers
	emerge --ask x11-base/xorg-server

}

graphic_install(){

	emerge --ask sudo

	echo "GNOME graphic interface installation"
	eselect profile set default/linux/amd64/17.1/desktop/gnome/systemd

	wget https://gitweb.gentoo.org/repo/gentoo.git/plain/gnome-base/gnome/gnome-40.0-r1.ebuild
	emerge --ask --getbinpkg gnome-base/gnome
	env-update && source /etc/profile
	getent group plugdev
	gpasswd -a $NAME plugdev
	
	rc-update add elogind boot
	rc-service elogind start
	
	emerge --ask --noreplace gui-libs/display-manager-init
	
	echo "DISPLAYMANAGER='gdm'" >> /etc/conf.d/display-manager
	rc-update add display-manager default
	#useradd -m -G users,wheel,audio -s /bin/bash $NAME
	#passwd $NAME 

}

error_exit(){

	echo "debug"
	echo "Error: $1"
	exit 1

}

	driver_install || error_exit "driver error"
	graphic_install || error_exit "graphic_install error"
