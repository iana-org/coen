#!/bin/bash
# mkinitramfs generates non-reproducible ramdisk images
# Reference https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=845034
# The initramfs-tools packages from tails fixed the above

set -x   # Print each command before executing it
set -e   # Exit immediately should a command fail
set -u   # Treat unset variables as an error and exit immediately

PKG1="initramfs-tools-core_0.130.0tails1_all.deb"
SHAPKG1="db1d9dcd6d0c9587136c5a65419ee9eaa7a8a20c163dd2718cd826056a893819  -"

PKG2="initramfs-tools_0.130.0tails1_all.deb"
SHAPKG2="36c39407b505015a80e666726018edad37211d594b862238475d59d3de4e0da9  -"

for PKG in "${PKG1} ${SHAPKG1}" "${PKG2} ${SHAPKG2}"
do
	set -- $PKG # parses variable PKG $1 name and $2 hash and $3 "-"
	cp $PACKAGE_DIR/$1 $WD/chroot/tmp
	echo "Calculating SHA-256 HASH of the $1"
	HASH=$(sha256sum < "$WD/chroot/tmp/$1")
		if [ "$HASH" != "$2  $3" ]
		then
			echo "ERROR: SHA-256 hashes mismatched"
			exit 1
		fi
	debuerreotype-chroot $WD/chroot dpkg -i /tmp/$1
	rm -f $WD/chroot/tmp/$1
done

# END
