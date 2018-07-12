#!/bin/bash
# fontconfig generates non-reproducible cache files under
# /var/cache/fontconfig
# Reference https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=864082
# The fontconfig packages from tails fixed the above

set -x   # Print each command before executing it
set -e   # Exit immediately should a command fail
set -u   # Treat unset variables as an error and exit immediately

PKG1="fontconfig-config_2.11.0-6.7.0tails4_all.deb"
SHAPKG1="390fdc4c915aeed379196335e672d6a9af6677e6d675093f8855c85953aae246  -"

PKG2="libfontconfig1_2.11.0-6.7.0tails4_amd64.deb"
SHAPKG2="933adbbead4fd8ced095b5f43fd82b092298aaf95436d8b051b2ee9a4abee917  -"

PKG3="fontconfig_2.11.0-6.7.0tails4_amd64.deb"
SHAPKG3="892a2c0b4f8e4874161165cb253755b3bd695ce238b30c3b8e5447ff269c2740  -"

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
