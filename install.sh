echo "ohmybsd"
# mock=$1
# if [ ! -z "$mock" ]; then
#     echo "Mock enabled"
# fi

echo ""
read -p "please enter user name? " user

init() {
    echo "Upgrading packages..."
    pkg update && pkg upgrade -y

    ## FETCH FreeBSD PORTS
    echo "Downloading Ports tree..."
    portsnap fetch auto
}

clearcache() {
    ## CLEAN CACHES AND AUTOREMOVES UNNECESARY FILES
    echo "Cleaning system..."
    echo ""
    pkg clean -y
    pkg autoremove -y
    echo ""
}

installxfce() {
    echo "Installing XFCE..."
    pkg install -y xorg xfce xfce4-goodies dbus
    pkg install -y lightdm lightdm-gtk-greeter

    pkg install -y xfce4-pulseaudio-plugin thunar-archive-plugin
    pkg install -y gnome-keyring xfce4-screenshooter-plugin ristretto atril-lite gnome-font-viewer mixer mixertui qjackctl
    pkg install -y gammy

    sysrc slim_enable="YES"
}

installkde() {
    echo "Installing KDE..."
    pkg install -y kde5 sddm
    sysctl net.local.stream.recvspace=65536
    sysctl net.local.stream.sendspace=65536
   
    sysrc sddm_enable="YES"
}

requiredpkgs() {
    pkg install -y drm-kmod
    pkg install -y sudo bash 
    pkg install -y lohit fonts-indic
}

installpkgs() {
    pkg install -y firefox
    pkg install -y htop bsdinfo barrier remmina
    pkg install -y vscode 
    # copyq-qt5
    pkg install -y neovim wget xarchiver unzip
    pkg install -y baobab networkmgr v4l-utils v4l_compat sctd brut clamtk
}

installautomount() {
    echo "Install automount pkgs..."
    pkg install -y automount exfat-utils fusefs-exfat fusefs-ntfs fusefs-ext2 fusefs-hfsfuse fusefs-lkl fusefs-simple-mtpfs dsbmd dsbmc
}

installchrome() {
    git clone https://github.com/mrclksr/linux-browser-installer.git
    cd linux-browser-installer
    ./linux-browser-installer install chrome
}

enablekeyboard_mm() {
    # Eabling Multimedia Keys.
    # https://forums.freebsd.org/threads/howto-enabling-multimedia-keys-gamepads-joysticks-for-desktop-usbhid.84464/

    echo "Enabling Multimedia keyboard."
    sysrc kld_list+="usbhid"
    echo 'hw.usb.usbhid.enable="1"' >> /boot/loader.conf
    
    
}

enablesystemservices() {
    ## ENABLES BASIC SYSTEM SERVICES
    echo "Enabling basic services"
    sysrc moused_enable="YES"
    sysrc dbus_enable="YES"
    sysrc dsbmd_enable="YES"
    
    sysrc lightdm_enable="YES"
    sysrc update_motd="NO"
    sysrc rc_startmsgs="NO"
    sysrc kld_list+="/boot/modules/i915kms.ko"
    sysrc kld_list+="fusefs"
    echo "Enabled basic services"
}

addxfcetouser() {
    ## CREATES .xinitrc SCRIPT FOR A REGULAR DESKTOP USER
    # cd
    # touch .xinitrc
    # echo 'exec xfce4-session' >>.xinitrc

    touch /usr/home/$user/.xinitrc
    echo 'exec xfce4-session' >>/usr/home/$user/.xinitrc
    echo "xfce enabled for $user"

}

addkdetouser() {
     touch /usr/home/$user/.xinitrc
     echo "exec ck-launch-session startplasma-x11" >>/usr/home/$user/.xinitrc
     echo "KDE enabled for $user"
}

addusertogroup() {
    if [ ! -z "$user" ]; then
        echo "Adding $user to video/realtime/wheel/operator groups"
        pw usermod $user -G video
        pw usermod $user -G realtime
        pw usermod $user -G wheel
        pw usermod $user -G operator
        pw usermod $user -G network

        ## ADDS USER TO SUDOERS
        echo "Adding $user to sudo"
        echo "$user ALL=(ALL:ALL) ALL" >>/usr/local/etc/sudoers

        ## CONFIGURES AUTOMOUNT FOR THE REGULAR DESKTOP USER
        touch /usr/local/etc/automount.conf
        echo "USERUMOUNT=YES" >>/usr/local/etc/automount.conf
        echo "USER=$user" >>/usr/local/etc/automount.conf
        echo "FM='thunar'" >>/usr/local/etc/automount.conf
        echo "NICENAMES=YES" >>/usr/local/etc/automount.conf

    else
        echo "User not available."
    fi
}


installrpmspkgs() {
	pkg install -y rpm4
	mkdir -p /var/lib/rpm
	/usr/local/bin/rpm --initdb
}


if [ ! -z "$user" ]; then
    echo "Init..."
    init
    requiredpkgs
    
    echo "Installing required pkgs..."
    installpkgs

    echo "Please select a Desktop Environment"
    echo "1. KDE"
    echo "2. XFCE"
    read -p "Option: " option

    if [ $option -eq 1 ]; then
            echo "Installing KDE..."
            installkde
            echo "Add kde to $user"
            addkdetouser
            
    elif [ $option -eq 2 ]; then
            echo "Installing XFCE..."
            installxfce
            echo "Add xfce to $user"
            addxfcetouser
    else
            echo "Invalid option"
    fi

    echo "Installing Automount..."
    installautomount
    
    echo "Adding $user to groups"
    addusertogroup

    echo "Enable System Services"
    enablesystemservices

    echo "Install Google Chrome"
    read -p "y/n: " cyn

    if [ $cyn = "y" ]; then
        installchrome
    fi

    echo "Istall multimedia keyboard"
    enablekeyboard_mm
    echo "Clear Cache..."
    clearcache
else
    echo "user name invalid..."
fi