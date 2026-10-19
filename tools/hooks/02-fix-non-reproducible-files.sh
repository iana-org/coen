#!/bin/bash
# Remove non-reproducible data

set -x   # Print each command before executing it
set -e   # Exit immediately should a command fail
set -u   # Treat unset variables as an error and exit immediately

# Remove non-reproducible snakeoil SSL key material and its symbolic link

debuerreotype-chroot $WD/chroot truncate -s 0 /etc/ssl/certs/ssl-cert-snakeoil.pem
debuerreotype-chroot $WD/chroot truncate -s 0 /etc/ssl/private/ssl-cert-snakeoil.key
debuerreotype-chroot $WD/chroot find "/etc/ssl/certs" -lname "ssl-cert-snakeoil.pem" -exec rm -f '{}' +

# Truncate non-reproducible files
debuerreotype-chroot $WD/chroot truncate -s 0 /etc/machine-id
debuerreotype-chroot $WD/chroot truncate -s 0 /var/lib/dbus/machine-id

# Removing python compiled bytecode
debuerreotype-chroot $WD/chroot find "/usr" -name "*.pyc" -exec rm -f '{}' +

# Remove the non-reproducible /run/cups/certs/ directory 
debuerreotype-chroot $WD/chroot find "/run" -type d -name "cups" -exec rm -rf '{}' +

# Remove the non-reproducible /var/log/journal/ directory
debuerreotype-chroot $WD/chroot find "/var/log" -type d -name "journal" -exec rm -rf '{}' +

# Truncate non-reproducible files
debuerreotype-chroot $WD/chroot truncate -s 0 /var/cache/debconf/config.dat
debuerreotype-chroot $WD/chroot truncate -s 0 /var/cache/debconf/config.dat-old

# END
