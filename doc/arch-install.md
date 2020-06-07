








# Arch Installation

Use the standard [Arch installation guide](https://wiki.archlinux.org/index.php/installation_guide) for reference.

# Preparation

## Keymap

`loadkeys dvorak-programmer`

## Boot

Boot a [bootable USB image](https://wiki.archlinux.org/index.php/USB_flash_installation_media)

You can use `wifi-menu` to connect to a secured network, temporarily.

## Start SSHD for easier installation from a remote system

```sh
passwd
systemctl start sshd
ip addr
```
Connect from a remote machine

`ssh root@some.ip.address`

# Filesystems

## Partitions

Find your destination disk with `lsblk -f`

Wipe everything
```sh
wipefs --all /dev/nvme0n1
```

Create partitions, with swap size matching physical RAM
```sh
parted /dev/nvme0n1
```
```
mktable GPT
mkpart ESP fat32 1MiB 513MiB
set 1 boot on
name 1 boot
mkpart primary 513MiB 33281MiB
name 2 swap
mkpart primary 33281MiB 100%
name 3 btrfs
quit
```

## Fat32 Boot

```sh
mkfs.vfat -n boot -F32 /dev/nvme0n1p1
```

## Swap

```sh
mkswap /dev/nvme0n1p2 -L swap
swapon /dev/nvme0n1p2
```

## Btrfs Root

```sh
mkfs.btrfs /dev/nvme0n1p3 -L btrfs
```

```sh
mount /dev/nvme0n1p3 /mnt
btrfs subvolume create /mnt/@root
btrfs subvolume create /mnt/@home
btrfs subvolume create ...
umount /mnt
```

## Mount All Filesystems

```sh
mount /dev/nvme0n1p3 /mnt -o subvol=/@root
mkdir -p /mnt/home /mnt/boot
mount /dev/nvme0n1p3 /mnt/home -o subvol=/@home
mount /dev/nvme0n1p1 /mnt/boot
```

`lsblk -f` should show something like this:
```
NAME        FSTYPE   FSVER LABEL       UUID                                 FSAVAIL FSUSE% MOUNTPOINT
loop0       squashfs 4.0                                                          0   100% /run/archiso/sfs/airootfs
sda         iso9660        ARCH_202006 2020-06-01-09-52-35-00
├─sda1      iso9660        ARCH_202006 2020-06-01-09-52-35-00                     0   100% /run/archiso/bootmnt
└─sda2      vfat     FAT16 ARCHISO_EFI FB44-50CD
nvme0n1
├─nvme0n1p1 vfat     FAT32 boot        226B-B351                               511M     0% /mnt/boot
├─nvme0n1p2 swap     1     swap        872db85f-9279-472b-ae4e-eee08d01796a
└─nvme0n1p3 btrfs          btrfs       4eb9de2a-5c04-4914-931d-081bbf9b8713    222G     0% /mnt/home
```

# Installation

## Bootstrap

Edit `/etc/pacman.d/mirrorlist` and put a local one on top

`pacstrap -i /mnt base base-devel`

## Setup /etc/fstab

`genfstab -U /mnt >> /mnt/etc/fstab`

Modify `/` for first fsck by setting the last field to 1.

Modify `/home` and `/boot` for second fsck by setting to 2.

`/mnt/etc/fstab` should look something like:
```
# /dev/nvme0n1p3 LABEL=btrfs
UUID=4eb9de2a-5c04-4914-931d-081bbf9b8713       /               btrfs           rw,relatime,ssd,space_cache,subvolid=256,subvol=/@root,subvol=@root     0 1

# /dev/nvme0n1p1 LABEL=boot
UUID=226B-B351          /boot           vfat            rw,relatime,fmask=0022,dmask=0022,codepage=437,iocharset=iso8859-1,shortname=mixed,utf8,errors=remount-ro       0 2

# /dev/nvme0n1p3 LABEL=btrfs
UUID=4eb9de2a-5c04-4914-931d-081bbf9b8713       /home           btrfs           rw,relatime,ssd,space_cache,subvolid=257,subvol=/@home,subvol=@home     0 2

# /dev/nvme0n1p2 LABEL=swap
UUID=c32b0c6b-e413-4eff-a873-6eab329dd245       none            swap            defaults        0 0
```

## Chroot

`arch-chroot /mnt /bin/bash`

## Install Packages Needed For Installation

`pacman -S btrfs-progs git linux-firmware networkmanager openssh pkgfile sudo efibootmgr vim wget zsh`

Link vi and others to vim:
```sh
ln -s /usr/bin/vim /usr/local/bin/ex
ln -s /usr/bin/vim /usr/local/bin/vi
ln -s /usr/bin/vim /usr/local/bin/view
```

## Locale And Time

Uncomment your desired UTF8 locale in `/etc/locale.gen`. Also `en_US` as too many things expect it :sigh:.

`locale-gen`

`echo LANG=en_AU.UTF-8 > /etc/locale.conf`

`ln -fs /usr/share/zoneinfo/Australia/Sydney /etc/localtime`

`hwclock --systohc --utc`

## Update pacman Packages And Installations To Current

`pacman -Suy`

## Install And Enable Basic Networking

```sh
systemctl enable sshd
systemctl enable NetworkManager
```

# Users

Invoke `visudo` and uncomment the following:

```sh
%wheel ALL=(ALL) ALL
```

Secure root first with `passwd`

Add a user e.g.
```sh
useradd -m -g users -G wheel,input -c "Alexander Courtis" -s /bin/zsh alex
passwd alex
```

Revised to this point, following along with a new system installation.
TODO:
retire efibootstub


# Booting

## EFISTUB Preparation

I'm bored with boot loaders and UEFI just doesn't need them. Simply point the EFI boot entry to the ESP, along with the kernel arguments.

Copy `bin/efibootstub` from this repository into `/usr/local/bin`

Determine the UUID of the your crypto_LUKS volume. Note that it's the raw device, not the crypto volume itself. e.g.

`blkid -s UUID -o value /dev/nvme0n1p2`

Create kernel command line in `/boot/kargs` e.g.
```
initrd=\initramfs-linux.img cryptdevice=UUID=b874fabd-ae06-485e-b858-6532cec92d3c:cryptlvm root=/dev/vg1/btrfs rootflags=subvol=/@root resume=/dev/vg1/swap rw quiet
```

If using Dell 5520, it's necessary to disable PCIe Active State Power Management as per (https://www.thomas-krenn.com/en/wiki/PCIe_Bus_Error_Status_00001100).

Append to `/boot/kargs`:
```
pcie_aspm=off
```

## Create initrd and kernel

Update the boot image configuration: `/etc/mkinitcpio.conf`

Add an encrypt hook and move the keyboard configration before it, so that we can type the passphrase.

Add lvm2 before filessystems so that we may open the volumes.

Add resume hook after filesystems.

Add usr and shutdown hooks so that the root filesystem may be retained during shutdown and cleanly unmounted.

Add consolefont and keymap after base, so that the disk encryption password may be entered sanely.

If using software raid, add mdadm_udev before encrypt.

```sh
HOOKS=(base consolefont keymap udev autodetect modconf block keyboard mdadm_udev encrypt lvm2 filesystems resume fsck usr shutdown)
```

(Re)generate the boot image:

`pacman -S linux`

# System Specific

## AMD CPU Microcode

Install AMD CPU microcode updater: `pacman -S amd-ucode`

Prepend `initrd=\amd-ucode.img ` to `/boot/kargs`.

## Intel CPU Microcode

Install Intel CPU microcode updater: `pacman -S intel-ucode`

Prepend `initrd=\intel-ucode.img ` to `/boot/kargs`.

## Nonstardard Keymap

Add the following to `/etc/vconsole.conf`

```
KEYMAP=dvorak-programmer
```

## Larger Console Fonts

In the case of a laptop with high resolution, it is necessary to increase the font size when using virtual consoles.

```
pacman -S terminus-font
```

Add the following to `/etc/vconsole.conf`

```
FONT=ter-v32n
```

## Create The EFISTUB

```sh
efibootstub /dev/nvme0n1 1
```

### Alternative: systemd-boot

Some terribad UEFI implementations such as Dell 5520 don't want to boot directly from UEFI; they only seem to support booting from an .efi file, hence we use systemd-boot.

```sh
bootctl --path=/boot install
```

Edit `/boot/loader/loader.conf` and change its contents to:
```
default arch
timeout 1
```

Add `/boot/loader/entries/arch.conf`, using `/boot/kargs` for options, with initrd moved up:

```
title Arch Linux
linux /vmlinuz-linux
initrd /intel-ucode.img
initrd /initramfs-linux.img
options cryptdevice=UUID=b874fabd-ae06-485e-b858-6532cec92d3c:cryptlvm root=/dev/vg1/btrfs rootflags=subvol=/@root resume=/dev/vg1/swap pcie_aspm=off rw
```

## Reboot

Populate the pacman cache first.

```sh
pkgfile --update
```

Exit chroot and reboot

## Remove Default User

Any default users (with known passwords) should be removed e.g.

`userdel -r alarm`

## Set Hostname

Use `nmtui` to setup the system network connection.

Apply the hostname e.g.:

`hostnamectl set-hostname gigantor`

Add the hostname to `/etc/hosts` first, as IPv4 local:

`127.0.0.1	gigantor`

## Enable NTP Sync

`timedatectl set-ntp true`

You can check this with: `timedatectl status`

## Setup CLI User Environment

Install your public/private keys under `~/.ssh`

See [Usage](#usage)

# Post Installation

## Video Driver

### Modern AMD

Add `amdgpu` to MODULES in `/etc/mkinitcpio.conf`

Install the X driver and (re)generate the boot image:

`pacman -S xf86-video-amdgpu libva-mesa-driver linux`

### Intel Only (lightweight laptop)

`pacman -S xf86-video-intel libva-intel-driver`

### Nvidia Only (desktop)

Unfortunately, the nouveau drivers aren't feature complete or performant, so use the dirty, proprietary ones. Linus extends the middle finger to nvidia.

`pacman -S nvidia nvidia-settings`

### Nvidia + Intel (heavy laptop)

I don't need the nvidia discrete GPU for a work laptop, so completely disable it.

If the discrete GPU is needed, optimus/prime may be used to enable it on demand.

`pacman -S xf86-video-intel libva-intel-driver bbswitch`

Load the bbswitch module via `/etc/modules-load.d/bbswitch.conf`:

```
bbswitch
```

Disable/enable the GPU on module load/unload via `/etc/modprobe.d/bbswitch.conf`:

```
options bbswitch load_state=0 unload_state=1
```

Ban the nouveau module, which can block bbswitch, via `/etc/modprobe.d/blacklisted.conf`:

```
blacklist nouveau
```

## Install Packages

Use [pacaur](https://github.com/ajlende/dotbot-pacaur) to manage system and AUR packages.

```sh
cd /tmp
git clone https://aur.archlinux.org/auracle-git.git
cd auracle-git
makepkg -sri
cd ..
git clone https://aur.archlinux.org/pacaur.git
cd pacaur
makepkg -sri
```

### Arch Packages I Like

#### Official

`pacman -S ...`

alacritty
autofs
calc
chromium
dmenu
efibootmgr
gpm
hunspell-en_AU
hunspell-en_GB
jq
keychain
network-manager-applet
nfs-utils
numlockx
noto-fonts
noto-fonts-emoji
noto-fonts-extra
pacman-contrib
parcellite
pavucontrol
pwgen
rsync
scrot
slock
sysstat
terminus-font
the_silver_searcher
tmux
ttf-dejavu
ttf-hack
udisks2
unzip
xautolock
xdg-utils
xmlstarlet
xorg-fonts-100dpi
xorg-fonts-75dpi
xorg-fonts-misc
xorg-server
xorg-xinit
xorg-xrandr
xsel
yq
zsh-completions

Enable gpm: `systemctl add-wants getty.target gpm.service`

#### AUR

`pacaur -S ...`

dapper
gron-bin
pulseaudio-ctl
rcm
redshift-minimal
todotxt
xlayoutdisplay

### Arch Packages Laptops Like

libinput-gestures
xorg-xbacklight

## Build Desktop Environment

### dwm and slstatus

Clone the following:
* `git@github.com:alex-courtis/dwm.git`
* `git@github.com:alex-courtis/slstatus.git`

Run for each:
`make && sudo make install`

### libinput-gestures

`libinput-gestures-setup autostart`

### Redshift

`systemctl enable --user redshift`

## Ready To Go

Reboot

Login at TTY1

Everything should start in your X environment... check `~/.local/share/xorg/Xorg.0.log`, `/tmp/x.${USER}.log`, `dmesg --human` and any console errors for oddities.
