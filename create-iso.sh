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
    linux-image-amd64 live-boot systemd-sysv \
    syslinux syslinux-common isolinux
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
mkdir -p $WD/image/isolinux

# Copying bootloader
cp -p $WD/chroot/boot/vmlinuz-* $WD/image/live/vmlinuz
cp -p $WD/chroot/boot/initrd.img-* $WD/image/live/initrd.img

# Creating the isolinux bootloader
cat > $WD/image/isolinux/isolinux.cfg << EOF
UI menu.c32

prompt 0
menu title coen-${RELEASE}

timeout 1

label coen-${RELEASE} Live amd64
menu label ^coen-${RELEASE} amd64
menu default
kernel /live/vmlinuz
append initrd=/live/initrd.img boot=live locales=en_US.UTF-8 keymap=us language=us net.ifnames=0 timezone=Etc/UTC live-media=removable nopersistence selinux=0 STATICIP=frommedia modprobe.blacklist=pcspkr,hci_uart,btintel,btqca,btbcm,bluetooth,snd_hda_intel,snd_hda_codec_realtek,snd_soc_skl,snd_soc_skl_ipc,snd_soc_sst_ipc,snd_soc_sst_dsp,snd_hda_ext_core,snd_soc_sst_match,snd_soc_core,snd_compress,snd_hda_core,snd_pcm,snd_timer,snd,soundcore

EOF

# Coping files for ISO booting
cp -p $WD/chroot/usr/lib/ISOLINUX/isolinux.bin $WD/image/isolinux/
cp -p $WD/chroot/usr/lib/ISOLINUX/isohdpfx.bin $WD/image/isolinux/
cp -p $WD/chroot/usr/lib/syslinux/modules/bios/menu.c32 $WD/image/isolinux/
cp -p $WD/chroot/usr/lib/syslinux/modules/bios/hdt.c32 $WD/image/isolinux/
cp -p $WD/chroot/usr/lib/syslinux/modules/bios/ldlinux.c32 $WD/image/isolinux/
cp -p $WD/chroot/usr/lib/syslinux/modules/bios/libutil.c32 $WD/image/isolinux/
cp -p $WD/chroot/usr/lib/syslinux/modules/bios/libmenu.c32 $WD/image/isolinux/
cp -p $WD/chroot/usr/lib/syslinux/modules/bios/libcom32.c32 $WD/image/isolinux/
cp -p $WD/chroot/usr/lib/syslinux/modules/bios/libgpl.c32 $WD/image/isolinux/
cp -p $WD/chroot/usr/share/misc/pci.ids $WD/image/isolinux/

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
xorriso -outdev $ISONAME -volid COEN \
 -map $WD/image/ / -chmod 0755 / -- -boot_image isolinux dir=/isolinux \
 -boot_image isolinux system_area=$WD/chroot/usr/lib/ISOLINUX/isohdpfx.bin \
 -boot_image isolinux partition_entry=gpt_basdat

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
