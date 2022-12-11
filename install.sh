echo "ohmybsd"
mock=$1
if [ ! -z "$mock" ]; then
    echo "Mock enabled"
fi

echo ""
read -p "please enter user name? " user

init() {
    echo "Upgrading packages..."
    pkg update && pkg upgrade -y

    ## FETCH FreeBSD PORTS
    echo "Downloading Ports tree..."
    portsnap fetch auto

    # ## FreeBSD SYSTEM TUNING FOR BEST DESKTOP EXPERIENCE
    # echo "Optimizing system parameters and firewall..."
    # echo ""
    # mv /etc/sysctl.conf /etc/sysctl.conf.bk
    # # mv /boot/loader.conf /boot/loader.conf.bk
    # mv /etc/login.conf /etc/login.conf.bk
    # cd /etc/ && fetch https://raw.githubusercontent.com/anandav/freebsd-xfce/main/sysctl.conf
    # fetch https://raw.githubusercontent.com/anandav/freebsd-xfce/main/login.conf
    # fetch https://raw.githubusercontent.com/anandav/freebsd-xfce/main/devfs.rules
    # # cd /boot/ && fetch https://raw.githubusercontent.com/anandav/freebsd-xfce/main/loader.conf
    # sysrc devfs_system_ruleset="desktop"
    # cd
    # touch /etc/pf.conf
    # echo 'block in all' >> /etc/pf.conf
    # echo 'pass out all keep state' >> /etc/pf.conf
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
    pkg install -y xorg xfce xfce4-goodies slim dbus
    pkg install -y xfce4-pulseaudio-plugin thunar-archive-plugin
    pkg install -y gnome-keyring xfce4-screenshooter-plugin ristretto atril-lite gnome-font-viewer mixer mixertui qjackctl
}

requiredpkgs(){
    pkg install -y drm-kmod
    pkg install -y sudo bash
}

installpkgs() {
    pkg install -y firefox
    pkg install -y htop neofetch gammy barrier
    pkg install -y vscode copyq-qt5
    pkg install -y vim wget xarchiver unzip
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

enablesystemservices() {
    ## ENABLES BASIC SYSTEM SERVICES
    echo "Enabling basic services"
    sysrc moused_enable="YES"
    sysrc dbus_enable="YES"
    sysrc dsbmd_enable="YES"
    sysrc slim_enable="YES"
    sysrc update_motd="NO"
    sysrc rc_startmsgs="NO"
    sysrc kld_list="/boot/modules/i915kms.ko"
    echo "Enabled basic services"
}

addxfcetouser() {
    ## CREATES .xinitrc SCRIPT FOR A REGULAR DESKTOP USER
    cd
    touch .xinitrc
    echo 'exec xfce4-session' >>.xinitrc
    echo ""
    echo

    touch /usr/home/$user/.xinitrc
    echo 'exec xfce4-session' >>/usr/home/$user/.xinitrc
    echo ""
    echo "$user enabled"

    # read -p "Want to enable XFCE for a regular user? (yes/no): " X
    # echo ""
    # if [ "$X" = "yes" ] || [ "$X" = "y" ]; then
    # fi
}

addusertogroup() {
    if [ ! -z "$user" ]; then
        echo "Adding $user to video/realtime/wheel/operator groups"
        pw usermod $user -G video
        pw usermod $user -G realtime
        pw usermod $user -G wheel
        pw usermod $user -G operator
        pw usermod $user -G network
        echo ""

        ## ADDS USER TO SUDOERS
        echo "Adding $user to sudo"
        echo "$user ALL=(ALL:ALL) ALL" >>/usr/local/etc/sudoers
        echo ""

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

if [ -z "$mock" ]; then
    echo "Init..."
    init
    requiredpkgs
    echo "Installing required pkgs..."
    installpkgs
    echo "Installing XFCE..."
    installxfce
    echo "Add xfce to $user"
    addxfcetouser
    echo "Adding $user to groups"
    addusertogroup
    echo "Enable System Services"
    enablesystemservices
    echo "Clear Cache..."
    clearcache
    echo "Install Google Chrome"
    installchrome
else
    echo "Mock..."
    echo "Init..."
    echo "Installing required pkgs..."
    echo "Installing XFCE..."
    echo "Add xfce to $user"
    echo "Adding $user to groups"
    echo "Enable System Services"
    echo "Clear Cache..."
    echo "Install Google Chrome"
fi
