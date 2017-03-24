# Create Partitions

parted /dev/sda
mklabel gpt
mkpart ESP fat32 1MiB 200MiB
set 1 boot on
name 1 efi

mkpart primary 200MiB 800MiB
name 2 boot

mkpart primary 800MiB 100%
set 3 lvm on
name 3 lvm
print


# Configure LUKS

modprobe dm-crypt
modprobe dm-mod
cryptsetup luksFormat -v -s 512 -h sha512 /dev/sda3
cryptsetup open /dev/sda3 luks_lvm

# Configure LVM

pvcreate /dev/mapper/luks_lvm
vgcreate arch /dev/mapper/luks_lvm
lvcreate -n home -L 70G arch
lvcreate -n root -L 120G arch
lvcreate -n swap -L 1G -C y arch

# Format Partitions

mkfs.fat -F32 /dev/sda1
mkfs.ext4 /dev/sda2
mkfs.btrfs -L root /dev/mapper/arch-root
mkfs.btrfs -L home /dev/mapper/arch-home
mkswap /dev/mapper/arch-swap

# Mount Partitions

swapon /dev/mapper/arch-swap
swapon -a ; swapon -s
mount /dev/mapper/arch-root /mnt
mkdir -p /mnt/{home,boot}
mount /dev/sda2 /mnt/boot
mount /dev/mapper/arch-home /mnt/home
mkdir /mnt/boot/efi
mount /dev/sda1 /mnt/boot/efi


# Install Arch Linux:

pacstrap /mnt base base-devel efibootmgr vim dialog xterm btrfs-progs grub --noconfirm
genfstav -U -p /mnt > /mnt/etc/fstab
arch-chroot /mnt /bin/bash

# Configuring mkinitcpio

vim /etc/mkinitcpio.conf

HOOKS="base udev autodetect modconf block encrypt lvm2 filesystems keyboard fsck"

# Generate a new initramfs image:

mkinitcpio -v -p linux


# Install grub

pacman -s grub --noconfirm
grub-install --efi-directory=/boot/efi


# Configure LUKS kernel parameters

vim /etc/default/grub
GRUB_CMDLINE_LINUX_DEFAULT="quiet resume=/dev/mapper/swap \
cryptdevice=/dev/sda3:luks_lvm"


# Autounlock looks encryted partition

dd if=/dev/urandom of=/crypto_keyfile.bin  bs=512 count=10
chmod 000 /crypto_keyfile.bin
chmod 600 /boot/initramfs-linux*
cryptsetup luksAddKey /dev/sda3 /crypto_keyfile.bin

# Now include /crypto_keyfile.bin file under FILES directive in mkinicpio.conf file.

vim /etc/mkinitcpio.conf 
FILES=/crypto_keyfile.bin


# Regenerate ramdisk file.

mkinitcpio -p linux

# Regenerate grub.cfg file:

grub-mkconfig -o /boot/grub/grub.cfg
grub-mkconfig -o /boot/efi/EFI/arch/grub.cfg


# Post installation configurations.

pacman -S git --noconfirm
git clone https://github.com/jmutai/dotfiles.git
cp dotfiles/setup/pacman.conf /etc/pacman.conf
cp dotfiles/setup/live-setup.sh .
chmod +x live-setup.sh
./live-setup.sh


# Unmount Partitions and reboot

exit
umount -R /mnt
reboot







