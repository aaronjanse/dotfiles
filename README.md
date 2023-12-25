# NixOS Dotfiles

<p float="left">
  <img src="./screenshots/term-subl.png" width="400" />
  <img src="./screenshots/subl.png" width="400" /> 
</p>
<p float="left">
  <img src="./screenshots/rofi.png" width="400" />
  <img src="./screenshots/htop.png" width="400" />
</p>

The content below is somewhat outdated.

## Installation

Download [nixos minimal](https://nixos.org/nixos/download.html), put it on a thumb drive:

```bash
sudo dd if=nixos-minimal.iso of=/dev/sdx status=progress
```

Once booted onto the thumb drive, you'll want to figure out which disk you are formatting:

```bash
lsblk
```

Now, for full disk encryption:

```bash
cryptsetup luksFormat /dev/DISK
cryptsetup luksOpen /dev/DISK nixosroot
mkfs.ext4 /dev/mapper/nixosroot
```

Now we mount our partition:
```
mount /dev/mapper/nixosroot /mnt
mkdir /mnt/boot
mount /dev/BOOTDISK /mnt/boot
```

Generate NixOS config:

```bash
nixos-generate-config --root /mnt
```

Setup networking: https://nixos.org/nixos/manual/index.html#sec-installation-booting-networking

To install these dotfiles:

```bash
cd /mnt/etc/nixos

nix-env -iA nixos.git
git clone git@github.com:aaronjanse/nixos
```

To finally install:

```bash
nixos-install
```
