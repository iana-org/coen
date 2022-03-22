#!/bin/bash
# gtk+2.0 and gtk+3.0 immodules.cache is not reproducible
# Reference https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=872729
# and https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=875700
# The gtk+ packages from tails fixed the above

set -x   # Print each command before executing it
set -e   # Exit immediately should a command fail
set -u   # Treat unset variables as an error and exit immediately

PKG1="libgtk2.0-common_2.24.31-2.0tails1_all.deb"
SHAPKG1="0862890d70bafeb6b4a7a1c1da05c90569e0147522d6526fad6d146d6335b79f  -"

PKG2="libgtk2.0-0_2.24.31-2.0tails1_amd64.deb"
SHAPKG2="a0ae2652c5ca8461752f17ab22aa385c588481351b7b4aeb199a3d23d6479c34  -"

PKG3="gir1.2-gtk-3.0_3.22.11-1.0tails1_amd64.deb"
SHAPKG3="01db265c90f351367c73cd7ecedeca2f490374579320c5240feecdc70040917e  -"

PKG4="gtk-update-icon-cache_3.22.11-1.0tails1_amd64.deb"
SHAPKG4="4e49e6161a93424700ced09d0225574d3f6dd406ba9f9e14c36a50e870faab16  -"

PKG5="libgtk-3-common_3.22.11-1.0tails1_all.deb"
SHAPKG5="605e3c77857d9c55932c7f497f56c70d46af65af59600e5507f42aea3832a848  -"

PKG6="libgtk-3-0_3.22.11-1.0tails1_amd64.deb"
SHAPKG6="a8946b779ccf305da8dadefa9d7d9402ccfe756246dd70a251e4375076a83648  -"

for PKG in "${PKG1} ${SHAPKG1}" "${PKG2} ${SHAPKG2}" "${PKG3} ${SHAPKG3}" "${PKG4} ${SHAPKG4}" "${PKG5} ${SHAPKG5}" "${PKG6} ${SHAPKG6}"
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
