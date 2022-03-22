#!/bin/bash
# fontconfig generates non-reproducible cache files under
# /var/cache/fontconfig
# Reference https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=864082
# Source packages available from https://deb.tails.boum.org/pool/main/f/fontconfig/
# The fontconfig packages from tails fixed the above

set -x   # Print each command before executing it
set -e   # Exit immediately should a command fail
set -u   # Treat unset variables as an error and exit immediately

PKG1="fontconfig-config_2.13.1-4.2.0tails1_all.deb"
SHAPKG1="fb7952c6000335ebbf3b72152635ff4f415c60fa3e95466297e32537e9e9b9b2  -"

PKG2="libfontconfig1_2.13.1-4.2.0tails1_amd64.deb"
SHAPKG2="109f877b4d834e45fafea4e27cb459f0a26981787c344300399856f0732f899b  -"

PKG3="fontconfig_2.13.1-4.2.0tails1_amd64.deb"
SHAPKG3="19af7757626609d6b58b9a0a323ca6f72560f4be1183da0086cb5daee5e76284  -"

for PKG in "${PKG1} ${SHAPKG1}" "${PKG2} ${SHAPKG2}" "${PKG3} ${SHAPKG3}"
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
