#!/bin/bash
# Main script for ISO image creation
#
###############################################################################
# PLEASE READ THIS
#
# One thing to note if you're ever in the position of having to change this
# script is that this script runs WITHIN THE CONTEXT OF THE ISO BUILD CONTAINER.
#
# It's kind of like Inception.  You type 'make all' at the command line and that
# generates the ISO build container.  Then this script is run from within the
# container, and it does a chroot to create the ISO image filesystem, also from
# within the build container.  But there are some things that run (e.g. apt-get)
# that would normally be run on the target system itself, so we use debuerreotype
# to fix that up so those scripts think they're executing from within the
# context of the target system.
###############################################################################

set -x   # Print each command before executing it
set -e   # Exit immediately should a command fail
set -u   # Treat unset variables as an error and exit immediately

source ./variables.sh
export _MAXNUM=6

# Creating a working directory
mkdir -p $WD

# Setting up the base Debian rootfs environment
debuerreotype-init $WD/chroot $DIST $DATE --arch=$ARCH
# root without password
debuerreotype-chroot $WD/chroot passwd -d root
# Installing all needed packages for COEN

# Allow access to contrib and non-free repos to download AMD graphics firmware blob
sed -i '${s/$/ contrib non-free/;}' $WD/chroot/etc/apt/sources.list
debuerreotype-apt-get $WD/chroot update
debuerreotype-chroot $WD/chroot DEBIAN_FRONTEND=noninteractive apt-get install -o Acquire::Check-Valid-Until=false --no-install-recommends --yes gpg wget ca-certificates aria2
debuerreotype-chroot $WD/chroot wget https://github.com/ilikenwf/apt-fast/archive/refs/tags/1.9.12.tar.gz && \
    tar zxvf 1.9.12.tar.gz && \
    cp apt-fast-1.9.12/apt-fast $WD/chroot/usr/local/sbin/ && \
    chmod +x $WD/chroot/usr/local/sbin/apt-fast && \
    cp apt-fast-1.9.12/apt-fast.conf $WD/chroot/etc && \
    sed -i "{s/#_MAXNUM=5/_MAXNUM=5/;}" $WD/chroot/etc/apt-fast.conf && \
    sed -i "{s/#_MAXCONPERSRV=10/_MAXCONPERSRV=5/;}" $WD/chroot/etc/apt-fast.conf && \
    sed -i "{s/#_SPLITCON=8/_SPLITCON=8/;}" $WD/chroot/etc/apt-fast.conf

debuerreotype-apt-get $WD/chroot update
debuerreotype-chroot $WD/chroot DEBIAN_FRONTEND=noninteractive apt-get -o Acquire::Check-Valid-Until=false --option="APT::Acquire::Retries=3" install \
    --no-install-recommends --yes \
    linux-image-amd64 usbutils live-boot systemd-sysv \
    syslinux syslinux-common isolinux

debuerreotype-chroot $WD/chroot DEBIAN_FRONTEND=noninteractive apt-get -o Acquire::Check-Valid-Until=false --option="APT::Acquire::Retries=3" install \
    --no-install-recommends --yes \
    iproute2 ifupdown alien pciutils usbutils dosfstools eject exfat-utils \
    lshw vim links2 xpdf tree openssl less \
    dialog \
    xserver-xorg-core xserver-xorg xfce4 xfce4-terminal xfce4-panel lightdm \
    xterm gvfs thunar-volman xfce4-power-manager \
    pkcs11-data pkcs11-dump p11-kit linux-headers-generic
debuerreotype-chroot $WD/chroot DEBIAN_FRONTEND=noninteractive apt-get -y install firmware-amd-graphics libgl1-mesa-dri libglx-mesa0 mesa-vulkan-drivers xserver-xorg-video-all
debuerreotype-apt-get $WD/chroot --yes --purge autoremove
debuerreotype-apt-get $WD/chroot --yes clean

# Display driver
#mkdir -p $WD/chroot/root/Desktop
#cp tools/amdgpu-install_21.50.2.50002-1_all.deb $WD/chroot/root/Desktop
#debuerreotype-chroot $WD/chroot dpkg -i /root/Desktop/amdgpu-install_21.50.2.50002-1_all.deb
#debuerreotype-chroot $WD/chroot/ DEBIAN_FRONTEND=noninteractive apt-get install --download-only amdgpu-dkms

# Verkada specific bits:
# * Place on the generated ISO all of the PDFs and other documentation relevant for our Thales Luna USB HSM
# * Install the HSM client software and drivers
# Copy over HSM documentation and tools, then install software
mkdir -p $WD/chroot/root/Desktop/hsm
cp -r $HSM_DIR/* $WD/chroot/root/Desktop/hsm
# Untar HSM software
debuerreotype-chroot $WD/chroot tar xvf /root/Desktop/hsm/610-000397-005_SW_Linux_Luna_Client_V10.4.1_RevA.tar -C /root/Desktop/hsm
# Install Luna HSM software.  Default options are 3 (Luna USB HSM) 1 (SDK)
# KVER overrides the auto-detected kernel version, which will be the kernel version of the generated Docker container
# Instead we want it to be the kernel version on the generated ISO
# The options at the end signify:
# Install ?  (y)
# 
TARGET_KVER=5.10.0-10-amd64
#
# Explainer on uname.sh: The HSM drivers/utils get compiled for the target OS during install, as set by Thales.
# We use a chroot environment to store the image, but Luna drivers/utils are compiled under the assumption they
# will execute on the installed system.  There's no cross-compilation or similar support, so I fake out uname by returning
# the kernel string as it would appear on the signing computer when you boot the ISO.  This is really fragile
# and sensitive to kernel updates, so be forewarned.
mv $WD/chroot/bin/uname $WD/chroot/bin/uname.old
chmod +x /uname.sh
cp /uname.sh $WD/chroot/bin/uname
cp /uname.sh $WD/chroot/usr/bin/uname

# Run the install script and type in installation options:
# Agree to license? (y)
# Install Luna USB (3)
# Next (n)
# Install Luna SDK (1)
# Install (i)
#strace -f -e execve,fork -o /tmp/1
debuerreotype-chroot $WD/chroot KVER=${TARGET_KVER} /root/Desktop/hsm/LunaClient_10.4.1-7_Linux/64/install.sh <<EOF
y
3
n
1
i
EOF
# Restore old uname
rm $WD/chroot/bin/uname
mv $WD/chroot/bin/uname.old $WD/chroot/bin/uname

# Applying hooks
for FIXES in $HOOK_DIR/*.sh
do
  $FIXES
done


# Setting network
echo "coen" > $WD/chroot/etc/hostname

cat > $WD/chroot/etc/hosts << EOF
127.0.0.1       localhost coen
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
echo "export PATH=:/usr/safenet/lunaclient/bin:/opt/icann/bin:/opt/Keyper/bin:\$PATH" >> $WD/chroot/root/.bashrc
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
mkdir -p $WD/image/EFI/boot
mkdir -p $WD/image/boot/grub/x86_64-efi
mkdir -p $WD/tmp

# Copying bootloader
cp -p $WD/chroot/boot/vmlinuz-* $WD/image/live/vmlinuz
cp -p $WD/chroot/boot/initrd.img-* $WD/image/live/initrd.img

KERNEL_PARAMS="boot=live locales=en_US.UTF-8 keymap=us language=us net.ifnames=0 timezone=Etc/UTC live-media=removable nopersistence selinux=0 STATICIP=frommedia modprobe.blacklist=pcspkr,hci_uart,btintel,btqca,btbcm,bluetooth,snd_hda_intel,snd_hda_codec_realtek,snd_soc_skl,snd_soc_skl_ipc,snd_soc_sst_ipc,snd_soc_sst_dsp,snd_hda_ext_core,snd_soc_sst_match,snd_soc_core,snd_compress,snd_hda_core,snd_pcm,snd_timer,snd,soundcore,e1000"


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
append initrd=/live/initrd.img ${KERNEL_PARAMS}

EOF

# Create GRUB bootloader menu
cat > $WD/image/boot/grub/grub.cfg <<EOF
search --set=root --file /COEN
set superusers=""

set default="0"
set timeout=30

# If X has issues finding screens, experiment with/without nomodeset.

menuentry "Debian Live [EFI/GRUB]" --unrestricted {
    insmod all_video
    linux (\$root)/live/vmlinuz ${KERNEL_PARAMS}
    initrd (\$root)/live/initrd.img
}

menuentry "Debian Live [EFI/GRUB] (nomodeset)" --unrestricted {
    insmod all_video
    linux (\$root)/live/vmlinuz nomodeset ${KERNEL_PARAMS}
    initrd (\$root)/live/initrd.img
}
EOF

# Create a 3rd boot config, this gets embedded in the EFI partition.  It finds the
# root and loads main GRUB from there
cat > $WD/tmp/grub-standalone.cfg <<EOF
search --set=root --file /COEN
set prefix=(\$root)/boot/grub/
configfile /boot/grub/grub.cfg
EOF

# Helps grub figure out which device contains the live filesystem
touch $WD/image/COEN

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

# Copying files for EFI boot
cp -r /usr/lib/grub/x86_64-efi/* "$WD/image/boot/grub/x86_64-efi/"

# Generate EFI bootable GRUB image
grub-mkstandalone \
    --format=x86_64-efi \
    --output=$WD/tmp/bootx64.efi \
    --locales="" \
    --fonts="" \
    "boot/grub/grub.cfg=$WD/tmp/grub-standalone.cfg"

# Create FAT16 UEFI bootable image
(cd $WD/image/EFI/boot && \
    dd if=/dev/zero of=efiboot.img bs=1M count=20 && \
    mkfs.vfat efiboot.img && \
    mmd -i efiboot.img efi efi/boot && \
    mcopy -vi efiboot.img $WD/tmp/bootx64.efi ::efi/boot/
)

# Delete the fontconfig cache as it creates random-looking files
rm -r $WD/chroot/var/cache/fontconfig

# Delete the manpage cache as it creates non-reproducible builds
rm -rf $WD/chroot/var/cache/man

# Fixing dates to SOURCE_DATE_EPOCH
debuerreotype-fixup $WD/chroot

# Fixing main folder timestamps to SOURCE_DATE_EPOCH
find "$WD/" -exec touch --no-dereference --date="@$SOURCE_DATE_EPOCH" '{}' +

# Compressing the chroot environment into a squashfs
# nbp: Removed -processors 1 since newer mksquashfs creates reproducible filesystems on multicore systems
mksquashfs $WD/chroot/ $WD/image/live/filesystem.squashfs -comp xz -Xbcj x86 -b 1024K -Xdict-size 1024K -no-exports -no-fragments -wildcards -ef $TOOL_DIR/mksquashfs-excludes

# Setting permissions for squashfs.img
chmod 644 $WD/image/live/filesystem.squashfs

# Fixing squashfs folder timestamps to SOURCE_DATE_EPOCH
find "$WD/image/" -exec touch --no-dereference --date="@$SOURCE_DATE_EPOCH" '{}' +

# Creating the iso
xorriso \
 -as mkisofs \
 -iso-level 3 \
 -o "$ISONAME" \
 -full-iso9660-filenames \
 -volid "COEN" \
 -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin \
 -eltorito-boot \
     isolinux/isolinux.bin \
     -no-emul-boot \
     -boot-load-size 4 \
     -boot-info-table \
     --eltorito-catalog isolinux/isolinux.cat \
 -eltorito-alt-boot \
     -e /EFI/boot/efiboot.img \
     -no-emul-boot \
     -isohybrid-gpt-basdat \
 -append_partition 2 0xef ${WD}/image/EFI/boot/efiboot.img \
    "${WD}/image"

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
