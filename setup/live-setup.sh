#!/usr/bin/env bash
set -e
username=""
# To be run just after chroot and installing git

echo "Setting locale and hostname...."

echo "arch.localhost" > /etc/hostname 
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
unlink /etc/localtime
ln -s /usr/share/zoneinfo/Africa/Nairobi  /etc/localtime


echo " Doing database update"
pacman -Syyu

echo ""
echo " Installing base packages"
sleep 3
pacman -S --noconfirm \
grub \
bash-completion \
sudo  \
dhclient \
efibootmgr \
btrfs-progs \
lvm2 


echo ""
echo "Installing Xorg server ..."
pacman -S xorg --noconfirm

echo ""
echo "Installing alsa and pulseaudio"
pacman -S --noconfirm \
pulseaudio-{equalizer,alsa,gconf} \
alsa-{utils,plugins,firmware} 

echo ""
echo "Installing synaptics touchpad drivers"
pacman -S --noconfirm  xf86-video-intel \
xf86-input-{keyboard,synaptics,mouse,libinput} 

echo "Installing i3 wm"
pacman -S --noconfirm  \
i3 \
dmenu \
rofi \
xorg-xinit

echo "*** Setting root password ***"
echo -n "Enter new root password: "
read pw1
echo -n "Retype new password: "
read pw2

# Check if the passwords match 
while [ "$pw1" != "$pw2" ]; do
    echo "Sorry, passwords do not match."
    echo ""
    echo -n "Enter root password: "
    read pw1
    echo -n "Retype new password: "
    read pw2
done

username=${root}
echo "${username}:${pw1}" | chpasswd

unset pw1
unset pw2
unset username

echo "*** Adding user and setting password ***"
read -p  "Enter username to add: " username
echo "You typed username ${username}"
useradd -m -G power,audio,wheel,storage $username

echo "*** Settting password for user ${username} ***"
read -p "Enter new password: " pw1
read -p "Retype new password: "  pw2

# Check if the passwords match 
while [ "$pw1" != "$pw2" ]; do
    echo "Sorry, passwords do not match."
    echo ""
    echo -n "Enter new password: "
    read pw1
    echo -n "Retype new password: "
    read pw2
done

echo "${username}:${pw1}" | chpasswd
if [ $? -eq 0 ]; then
echo ""
echo "Paswword set successfully"
else
    echo "Password set failed"
fi

