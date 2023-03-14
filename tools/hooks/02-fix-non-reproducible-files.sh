#!/bin/bash
# Fixing non-reproducible files

set -x   # Print each command before executing it
set -e   # Exit immediately should a command fail
set -u   # Treat unset variables as an error and exit immediately

# Truncating the snakeoil SSL key pair and deleting the symbolic link generated
# by ssl-cert because is not reproducible

debuerreotype-chroot $WD/chroot truncate -s 0 /etc/ssl/certs/ssl-cert-snakeoil.pem
debuerreotype-chroot $WD/chroot truncate -s 0 /etc/ssl/private/ssl-cert-snakeoil.key
debuerreotype-chroot $WD/chroot find "/etc/ssl/certs" -lname "ssl-cert-snakeoil.pem" -exec rm -f '{}' +

# Truncating non-reproducible file
debuerreotype-chroot $WD/chroot truncate -s 0 /etc/machine-id

# Removing python compiled bytecode
debuerreotype-chroot $WD/chroot find "/usr" -name "*.pyc" -exec rm -f '{}' +

# fontconfig generates non-reproducible cache files in /var/cache/fontconfig
# Reference https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=864082
# This is fixed in fontconfig >= 2.13.1-4.4

debuerreotype-chroot $WD/chroot sed -i "$ a\deb \
http://snapshot.debian.org/archive/debian/$(date --date "$DATE" '+%Y%m%dT%H%M%SZ') \
"$DIST_ADD" main" /etc/apt/sources.list

debuerreotype-apt-get $WD/chroot update

cp $FONTC_DIR/*.deb $WD/chroot/var/cache/apt/archives/

debuerreotype-chroot $WD/chroot DEBIAN_FRONTEND=noninteractive apt-get -o Acquire::Check-Valid-Until=false install \
  --no-install-recommends --yes \
	fontconfig-config=2.13.1-4.5 libfontconfig1=2.13.1-4.5 fontconfig=2.13.1-4.5

debuerreotype-apt-get $WD/chroot --yes --purge autoremove
debuerreotype-apt-get $WD/chroot --yes clean

# Regenerating the font cache
debuerreotype-chroot $WD/chroot fc-cache --force --really-force --system-only --verbose

# Removing /run/cups/certs/ non-reproducible directory 
debuerreotype-chroot $WD/chroot find "/run" -type d -name "cups" -exec rm -rf '{}' +

# Removing /var/log/journal/ non-reproducible directory
debuerreotype-chroot $WD/chroot find "/var/log" -type d -name "journal" -exec rm -rf '{}' +

# Truncating non-reproducible files
debuerreotype-chroot $WD/chroot truncate -s 0 /var/cache/debconf/config.dat
debuerreotype-chroot $WD/chroot truncate -s 0 /var/cache/debconf/config.dat-old

# Checking and fixing initrd if necessary
echo "Calculating SHA-256 HASH of the initrd"
INITRDFINALHASH=$(sha256sum < "${WD}"/chroot/boot/initrd.img-5.10.0-20-amd64)
  if [ "$INITRDFINALHASH" != "$INITRD_FINAL_SHASUM" ]
    then
      echo "Warning: SHA-256 hashes do not match. Reproduction of the initrd-img failed"
      echo "Fixing initrd-img"
      tar --overwrite --preserve-permissions -zxvf $PACKAGE_DIR/initrd.img-5.10.0-20-amd64.tgz  --directory $WD/chroot/boot/
  else
      echo "Successfully reproduced initrd"
  fi

# END
