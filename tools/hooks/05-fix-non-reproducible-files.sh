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

# Truncating not reproducible file
debuerreotype-chroot $WD/chroot truncate -s 0 /etc/machine-id

# Removing python compiled bytecode
debuerreotype-chroot $WD/chroot find "/usr" -name "*.pyc" -exec rm -f '{}' +

# END
