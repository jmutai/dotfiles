Here is Arch Linux Installation Cheatsheet i made for my own reference. This Arch Linux Installation Cheatsheet  uses UEFI and LVM on LUKS for the installation.
<!--more-->

### Create Partitions
```bash
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
```


### Configure LUKS

```bash
modprobe dm-crypt
modprobe dm-mod
cryptsetup luksFormat -v -s 512 -h sha512 /dev/sda3
cryptsetup open /dev/sda3 luks_lvm
```

#### Configure LVM

```bash
pvcreate /dev/mapper/luks_lvm
vgcreate arch /dev/mapper/luks_lvm
lvcreate -n home -L 70G arch
lvcreate -n root -L 120G arch
lvcreate -n swap -L 1G -C y arch
```

### Format Partitions

```bash
mkfs.fat -F32 /dev/sda1
mkfs.ext4 /dev/sda2
mkfs.btrfs -L root /dev/mapper/arch-root
mkfs.btrfs -L home /dev/mapper/arch-home
mkswap /dev/mapper/arch-swap
```

### Mount Partitions

```bash
swapon /dev/mapper/arch-swap
swapon -a ; swapon -s
mount /dev/mapper/arch-root /mnt
mkdir -p /mnt/{home,boot}
mount /dev/sda2 /mnt/boot
mount /dev/mapper/arch-home /mnt/home
mkdir /mnt/boot/efi
mount /dev/sda1 /mnt/boot/efi
```


### Install Arch Linux:

```bash
pacstrap /mnt base base-devel efibootmgr vim dialog xterm btrfs-progs grub --noconfirm
genfstav -U -p /mnt > /mnt/etc/fstab
arch-chroot /mnt /bin/bash
```

### Configuring mkinitcpio

```bash
vim /etc/mkinitcpio.conf
```
Modify the line to add `encrypt` and `lvm2`:

```bash
HOOKS="base udev autodetect modconf block encrypt lvm2 filesystems keyboard fsck"
```

### Generate a new initramfs image:
```bash
mkinitcpio -v -p linux
```


### Install grub

```bash
pacman -s grub --noconfirm
grub-install --efi-directory=/boot/efi
```


### Configure LUKS kernel parameters

```bash
vim /etc/default/grub
```
Add the line:

```bash
GRUB_CMDLINE_LINUX_DEFAULT="quiet resume=/dev/mapper/swap cryptdevice=/dev/sda3:luks_lvm"
```


### Auto-unlock luks encryted partition

```bash
dd if=/dev/urandom of=/crypto_keyfile.bin  bs=512 count=10
chmod 000 /crypto_keyfile.bin
chmod 600 /boot/initramfs-linux*
cryptsetup luksAddKey /dev/sda3 /crypto_keyfile.bin
```

### Remodify  mkinicpio.conf 

Now include `/crypto_keyfile.bin` file under FILES directive in `mkinicpio.conf` file.

```bash
vim /etc/mkinitcpio.conf
```
Add the Line

```bash
FILES=/crypto_keyfile.bin
```


### Regenerate ramdisk file.

```bash
mkinitcpio -p linux
```

### Regenerate grub.cfg file:

```bash
grub-mkconfig -o /boot/grub/grub.cfg
grub-mkconfig -o /boot/efi/EFI/arch/grub.cfg
```


### Post installation configurations.

Remember to modify `live-setup.sh` accordingly:

```bash
pacman -S git --noconfirm
git clone https://github.com/jmutai/dotfiles.git
cp dotfiles/setup/pacman.conf /etc/pacman.conf
cp dotfiles/setup/live-setup.sh .
chmod +x live-setup.sh
./live-setup.sh
```


### Unmount Partitions and reboot

```bash
exit
umount -R /mnt
reboot
```








