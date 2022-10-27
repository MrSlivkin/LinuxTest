#!/bin/bash

MAKE_PATH=/etc/portage/make.conf

driver_install(){

	echo "drivers update installation"
	echo "creating new user:"
	read NAME

	useradd -m -G users,wheel,audio,video -s /bin/bash $NAME
	echo "password for $NAME"

	passwd $NAME

	echo "VIDEO_CARDS='amdgpu radeon radensi'" >>$MAKE_PATH
	echo "INPUT_DEVICES='synaptics libinput'" >>$MAKE_PATH

	emerge --pretend --verbose x11-base/xorg-drivers
	emerge --ask x11-base/xorg-server
	
	rc-update add elogind boot
	rc-service elogind start
	echo "DISPLAYMANAGER='gdm'" >>
	emerge --ask --noreplace gui-libs/display-manager-init
}

graphic_install(){

	echo "graphic GNOME interface installation"
	#eselect profile set default/linux/amd64/17.1/desktop/gnome/systemd
	emerge --ask gnome-base/gnome

	env-update && sourse /etc/profile
	getent group plugdev

	gpasswd -a $NAME plugdev
}

update_sys_installation(){
emerge --ask app-portage/cfg-update
cfg-update -u
}

debugger(){
	echo "Error: $1"
	exit 1

}
	update_sys_installation || debugger "update installation error"
	driver_install || debugger "driver error"
	graphic_install || debugger "graphic_install error"
