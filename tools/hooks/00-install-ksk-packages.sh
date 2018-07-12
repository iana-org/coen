#!/bin/bash
# Installs KSK software and XFCE customisation from Debian packages

set -x   # Print each command before executing it
set -e   # Exit immediately should a command fail
set -u   # Treat unset variables as an error and exit immediately

PKG1="ksk-tools-0.1.0coen_amd64.deb"
SHAPKG1="93e954744ec11e1d6837a792e26cc93b88f0735f7184337c4e65babca65503ab  -"

PKG2="ksk-xfce-custom-0.1.0coen_amd64.deb"
SHAPKG2="2080347093bc714b92d2f02e9c19e51ca23804776c2b52958c25630330b25f1d  -"

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
