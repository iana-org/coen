#!/bin/bash
# gdk-pixbuf's loaders.cache is not reproducible
# Reference https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=875704
# giomodule.cache is not reproducible
# Reference https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=873625
# The file /etc/shadow is not reproducible
# Reference https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=857803
# The packages from sid (unstable) fixed the above

set -x   # Print each command before executing it
set -e   # Exit immediately should a command fail
set -u   # Treat unset variables as an error and exit immediately

# Adding sid (unstable) to /etc/apt/sources.list
debuerreotype-chroot $WD/chroot sed -i "$ a\deb \
http://snapshot.debian.org/archive/debian/$(date --date "$DATE" '+%Y%m%dT%H%M%SZ') \
sid main" /etc/apt/sources.list

# Installing sid (unstable) packages
debuerreotype-apt-get $WD/chroot update
debuerreotype-chroot $WD/chroot DEBIAN_FRONTEND=noninteractive apt-get -o Acquire::Check-Valid-Until=false install \
  --no-install-recommends --yes -t sid \
	gir1.2-gdkpixbuf-2.0 libgdk-pixbuf2.0-common libgdk-pixbuf2.0-0 \
	libglib2.0-0 \
	login passwd
debuerreotype-apt-get $WD/chroot --yes --purge autoremove
debuerreotype-apt-get $WD/chroot --yes clean

# Turning off the shadow passwords
debuerreotype-chroot $WD/chroot shadowconfig off
debuerreotype-chroot $WD/chroot rm -f /etc/shadow-

# END
