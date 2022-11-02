echo "Upgrading packages..."
echo ""
pkg update && pkg upgrade -y
echo ""

## FETCH FreeBSD PORTS
echo "Downloading Ports tree...";
echo ""
portsnap fetch auto
echo ""

## INSTALLS BASE DESKTOP AND CORE UTILS
echo "Installing XFCE and required software..."
echo ""
pkg install -y xorg xfce xfce4-goodies slim dbus
pkg install -y sudo fish htop neoftech firefox
pkg install -y vscode barrier
# pkg install -y vim bash wget xfce4-pulseaudio-plugin thunar-archive-plugin xarchiver unzip
# pkg install -y gnome-keyring xfce4-screenshooter-plugin ristretto atril-lite gnome-font-viewer mixer mixertui qjackctl
# pkg install -y baobab networkmgr v4l-utils v4l_compat webcamd pwcview sctd brut clamtk 

# ## INSTALLS AUTOMOUNT AND FILESYSTEM SUPPORT
echo ""
echo "Install automount pkgs..."
echo ""
pkg install -y automount exfat-utils fusefs-exfat fusefs-ntfs fusefs-ext2 fusefs-hfsfuse fusefs-lkl fusefs-simple-mtpfs dsbmd dsbmc
echo ""

## ENABLES BASIC SYSTEM SERVICES
echo "Enabling basic services"
sysrc moused_enable="YES"
sysrc dbus_enable="YES"
sysrc dsbmd_enable=YES
sysrc slim_enable="YES"
sysrc update_motd="NO"
sysrc rc_startmsgs="NO"
echo ""

## CREATES .xinitrc SCRIPT FOR A REGULAR DESKTOP USER
cd
touch .xinitrc
echo 'exec xfce4-session' >> .xinitrc
echo ""
echo ; read -p "Want to enable XFCE for a regular user? (yes/no): " X;
echo ""
if [ "$X" = "yes" ] || ["$X" = "y"]
then
    echo ; read -p "For what user? " user;
    touch /usr/home/$user/.xinitrc
    echo 'exec xfce4-session' >> /usr/home/$user/.xinitrc
    echo ""
    echo "$user enabled"
else fi


## SPECIAL PERMISSIONS FOR USB DRIVES AND WEBCAM
echo "perm    /dev/da0        0666" >> /etc/devfs.conf
echo "perm    /dev/da1        0666" >> /etc/devfs.conf
echo "perm    /dev/da2        0666" >> /etc/devfs.conf
echo "perm    /dev/da3        0666" >> /etc/devfs.conf
echo "perm    /dev/video0     0666" >> /etc/devfs.conf
echo ""

## ADDS USER TO CORE GROUPS
if [ ! -z "$user"]
then
    echo "Adding $user to video/realtime/wheel/operator groups"
    pw usermod $user -G video
    pw usermod $user -G realtime
    pw usermod $user -G wheel
    pw usermod $user -G operator
    pw usermod $user -G network
    pw usermod $user -G webcamd
    echo ""

    ## ADDS USER TO SUDOERS
    echo "Adding $user to sudo"
    echo "$user ALL=(ALL:ALL) ALL" >> /usr/local/etc/sudoers
    echo ""

    ## CONFIGURES AUTOMOUNT FOR THE REGULAR DESKTOP USER
    touch /usr/local/etc/automount.conf
    echo "USERUMOUNT=YES" >> /usr/local/etc/automount.conf
    echo "USER=$user" >> /usr/local/etc/automount.conf
    echo "FM='thunar'" >> /usr/local/etc/automount.conf
    echo "NICENAMES=YES" >> /usr/local/etc/automount.conf

else fi

## ENABLES LINUX COMPAT LAYER
echo "Enabling Linux compat layer..."
echo ""
kldload linux.ko
sysrc linux_enable="YES"
echo ""

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



## CLEAN CACHES AND AUTOREMOVES UNNECESARY FILES
echo "Cleaning system..."
echo ""
pkg clean -y
pkg autoremove -y
echo ""

