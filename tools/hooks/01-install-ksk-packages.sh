#!/bin/bash
# Installs KSK software and XFCE customization

set -x   # Print each command before executing it
set -e   # Exit immediately should a command fail
set -u   # Treat unset variables as an error and exit immediately

PKG1="ksk-tools-1.0.0coen_amd64.deb"
SHAPKG1="27c88370b4d0ed93bd0d9455c1821143866bbddc26d1e2679ab7bcabb3dbbd40  -"

PKG2="ksk-xfce-custom-0.1.0coen_amd64.deb"
SHAPKG2="2080347093bc714b92d2f02e9c19e51ca23804776c2b52958c25630330b25f1d  -"

PKG3="kskm_0.0.1_efd2237_amd64.deb"
SHAPKG3="e81fb408e40d81a9274cf43fbbe0716f290fc88cb2a9802b9a9fd436612987c7  -"


for PKG in "${PKG1} ${SHAPKG1}" "${PKG2} ${SHAPKG2}" "${PKG3} ${SHAPKG3}"
do
	set -- $PKG # parses variable PKG $1 name and $2 hash and $3 "-"
	cp $PACKAGE_DIR/$1 $WD/chroot/tmp
	echo "Calculating SHA-256 HASH of the $1"
	HASH=$(sha256sum < "$WD/chroot/tmp/$1")
		if [ "$HASH" != "$2  $3" ]
		then
			echo "ERROR: SHA-256 hashes do not match"
			exit 1
		fi
	debuerreotype-chroot $WD/chroot dpkg -i /tmp/$1
	rm -f $WD/chroot/tmp/$1
done

# Activate Python environment
echo "source /opt/venvs/kskm/bin/activate" >> $WD/chroot/root/.bashrc

# END
