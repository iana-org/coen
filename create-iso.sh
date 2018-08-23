#!/bin/bash
# Main script for ISO image creation

set -x   # Print each command before executing it
set -e   # Exit immediately should a command fail
set -u   # Treat unset variables as an error and exit immediately

source ./variables.sh

# Creating a working directory
mkdir -p $WD

# Setting up the base Debian rootfs environment
debuerreotype-init $WD/chroot $DIST $DATE --arch=$ARCH
# root without password
debuerreotype-chroot $WD/chroot passwd -d root
# Installing all needed packages for COEN
debuerreotype-apt-get $WD/chroot update
debuerreotype-chroot $WD/chroot DEBIAN_FRONTEND=noninteractive apt-get -o Acquire::Check-Valid-Until=false install \
    --no-install-recommends --yes \
    linux-image-$ARCH live-boot systemd-sysv \
    grub-pc-bin grub-efi-ia32-bin grub-efi-amd64-bin
debuerreotype-chroot $WD/chroot DEBIAN_FRONTEND=noninteractive apt-get -o Acquire::Check-Valid-Until=false install \
    --no-install-recommends --yes \
    iproute2 ifupdown pciutils usbutils dosfstools eject exfat-utils \
    vim links2 xpdf cups cups-bsd enscript libbsd-dev tree openssl less iputils-ping \
    xserver-xorg-core xserver-xorg xfce4 xfce4-terminal xfce4-panel lightdm system-config-printer \
    xterm gvfs thunar-volman xfce4-power-manager
debuerreotype-apt-get $WD/chroot --yes --purge autoremove
debuerreotype-apt-get $WD/chroot --yes clean

# Applying hooks
for FIXES in $HOOK_DIR/*
do
  $FIXES
done

# Setting network
echo "coen" > $WD/chroot/etc/hostname

cat > $WD/chroot/etc/hosts << EOF
127.0.0.1       localhost coen
192.168.0.2     hsm
EOF

cat > $WD/chroot/etc/network/interfaces.d/coen-network << EOF
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
  address 192.168.0.1
  netmask 255.255.255.0
EOF

# Profile in .bashrc to work with xfce terminal
echo "export PATH=:/opt/icann/bin:/opt/Keyper/bin:\$PATH" >> $WD/chroot/root/.bashrc
# ls with color
sed -i -r -e '9s/^#//' \
          -e '10s/^#//' \
          -e '11s/^#//' \
    $WD/chroot/root/.bashrc

# Configure autologin
for NUMBER in $(seq 1 6)
		do
      mkdir -p $WD/chroot/etc/systemd/system/getty@tty${NUMBER}.service.d

cat > $WD/chroot/etc/systemd/system/getty@tty${NUMBER}.service.d/live-config_autologin.conf << EOF
[Service]
Type=idle
ExecStart=
ExecStart=-/sbin/agetty --autologin root --noclear %I \$TERM
TTYVTDisallocate=no
EOF
done

# XFCE root auto login
sed -i -r -e "s|^#.*autologin-user=.*\$|autologin-user=root|" \
          -e "s|^#.*autologin-user-timeout=.*\$|autologin-user-timeout=0|" \
    $WD/chroot/etc/lightdm/lightdm.conf

sed -i --regexp-extended \
    '11s/.*/#&/' \
    $WD/chroot/etc/pam.d/lightdm-autologin

# Disabling lastlog since autologin is enabled
sed -i '/^[^#].*pam_lastlog\.so/s/^/# /' $WD/chroot/etc/pam.d/login

# Making sure that the xscreensaver is off
rm -f $WD/chroot/etc/xdg/autostart/xscreensaver.desktop

# Defining mount point /media/ for HSMFD, HSMFD1 and KSRFD
cat > $WD/chroot/etc/udev/rules.d/99-udisks2.rules << EOF
# UDISKS_FILESYSTEM_SHARED
# ==1: mount filesystem to a shared directory (/media/VolumeName)
# ==0: mount filesystem to a private directory (/run/media/USER/VolumeName)
# See udisks(8)
ENV{ID_FS_USAGE}=="filesystem|other|crypto", ENV{UDISKS_FILESYSTEM_SHARED}="1"
EOF

# Creating boot directories
mkdir -p $WD/image/live
mkdir -p $WD/image/boot/grub
mkdir -p $WD/image/efi/boot

# Copying bootloader
cp -p $WD/chroot/boot/vmlinuz-* $WD/image/boot/vmlinuz
cp -p $WD/chroot/boot/initrd.img-* $WD/image/boot/initrd.img

# Creating the GRUB configuration
cp -a $WD/chroot/usr/lib/grub/i386-pc $WD/image/boot/grub/i386-pc
cp -a $WD/chroot/usr/lib/grub/i386-efi $WD/image/boot/grub/i386-efi
cp -a $WD/chroot/usr/lib/grub/x86_64-efi $WD/image/boot/grub/x86_64-efi
cp -p $WD/chroot/usr/share/grub/unicode.pf2 $WD/image/boot/grub/unicode.pf2
cat > $WD/image/boot/grub/grub.cfg << EOF

set timeout=1

if loadfont /boot/grub/fonts/unicode.pf2 ; then
	set gfxmode=auto
	insmod efi_gop
	insmod efi_uga
	insmod gfxterm
	terminal_output gfxterm
fi

set menu_color_normal=white/black
set menu_color_highlight=black/light-gray

menuentry "coen-${RELEASE} ${ARCH}" --hotkey "c" --id "coen-${RELEASE} Live ${ARCH}" {
	set gfxpayload=keep
	linux	/boot/vmlinuz  boot=live locales=en_US.UTF-8 keymap=us language=us net.ifnames=0 timezone=Etc/UTC live-media=removable nopersistence selinux=0 STATICIP=frommedia modprobe.blacklist=pcspkr,hci_uart,btintel,btqca,btbcm,bluetooth,snd_hda_intel,snd_hda_codec_realtek,snd_soc_skl,snd_soc_skl_ipc,snd_soc_sst_ipc,snd_soc_sst_dsp,snd_hda_ext_core,snd_soc_sst_match,snd_soc_core,snd_compress,snd_hda_core,snd_pcm,snd_timer,snd,soundcore
	initrd	/boot/initrd.img
}

EOF

# Creating GRUB images
grub-mkimage --directory "$WD/chroot/usr/lib/grub/i386-pc" --prefix '/boot/grub' --output "$WD/image/boot/grub/i386-pc/eltorito.img" --format 'i386-pc-eltorito' --compression 'auto'  --config "$WD/image/boot/grub/grub.cfg" 'biosdisk' 'iso9660'
grub-mkimage --directory "$WD/chroot/usr/lib/grub/i386-efi" --prefix '()/boot/grub' --output "$WD/image/efi/boot/bootia32.efi" --format 'i386-efi' --compression 'auto'  --config "$WD/image/boot/grub/grub.cfg" 'part_gpt' 'part_msdos' 'fat' 'part_apple' 'iso9660'
grub-mkimage --directory "$WD/chroot/usr/lib/grub/x86_64-efi" --prefix '()/boot/grub' --output "$WD/image/efi/boot/bootx64.efi" --format 'x86_64-efi' --compression 'auto'  --config "$WD/image/boot/grub/grub.cfg" 'part_gpt' 'part_msdos' 'fat' 'part_apple' 'iso9660'

# Creating EFI boot image
mformat -C -f 2880 -L 16 -N 0 -i "$WD/image/boot/grub/efi.img" ::.
mcopy -s -i "$WD/image/boot/grub/efi.img" "$WD/image/efi" ::/.

# Fixing dates to SOURCE_DATE_EPOCH
debuerreotype-fixup $WD/chroot

# Fixing main folder timestamps to SOURCE_DATE_EPOCH
find "$WD/" -exec touch --no-dereference --date="@$SOURCE_DATE_EPOCH" '{}' +

# Compressing the chroot environment into a squashfs
mksquashfs $WD/chroot/ $WD/image/live/filesystem.squashfs -comp xz -Xbcj x86 -b 1024K -Xdict-size 1024K -no-exports -processors 1 -no-fragments -wildcards -ef $TOOL_DIR/mksquashfs-excludes

# Setting permissions for squashfs.img
chmod 644 $WD/image/live/filesystem.squashfs

# Fixing squashfs folder timestamps to SOURCE_DATE_EPOCH
find "$WD/image/" -exec touch --no-dereference --date="@$SOURCE_DATE_EPOCH" '{}' +

# Creating the iso
xorriso -as mkisofs -graft-points -b 'boot/grub/i386-pc/eltorito.img' -no-emul-boot -boot-load-size 4 -boot-info-table --grub2-boot-info --grub2-mbr "$WD/chroot/usr/lib/grub/i386-pc/boot_hybrid.img" --efi-boot 'boot/grub/efi.img' -efi-boot-part --efi-boot-image --protective-msdos-label -o "$ISONAME" -r "$WD/image" --sort-weight 0 '/' --sort-weight 1 '/boot'

echo "Calculating SHA-256 HASH of the $ISONAME"
NEWHASH=$(sha256sum < "${ISONAME}")
  if [ "$NEWHASH" != "$SHASUM" ]
    then
      echo "ERROR: SHA-256 hashes mismatched reproduction failed"
      echo "Please send us an issue report: https://github.com/iana-org/coen"
  else
      echo "Successfully reproduced coen-${RELEASE}"
  fi

# END
