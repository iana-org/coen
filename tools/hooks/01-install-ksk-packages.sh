#!/bin/bash

set -x   # Print each command before executing it
set -e   # Exit immediately should a command fail
set -u   # Treat unset variables as an error and exit immediately

# Installs KSK software and XFCE customization packages
cp $PACKAGE_DIR/*.deb $WD/chroot/tmp/
debuerreotype-chroot $WD/chroot dpkg -i -R /tmp/
rm -f $WD/chroot/tmp/*.deb

# Activate Python environment
echo "source /opt/venvs/kskm/bin/activate" >> $WD/chroot/root/.bashrc

# Thales Luna USB HSM 7 
# Checking the Luna HSM Client package hash 
debuerreotype-chroot $WD/chroot sha256sum -c $(ls -1 $WD/chroot/opt/luna/*.sha256 | sed 's,'"${WD}/chroot/"',,')

# Copying development packages
cp $DEV_DIR/*.deb $WD/chroot/var/cache/apt/archives/

debuerreotype-chroot $WD/chroot DEBIAN_FRONTEND=noninteractive apt-get -o Acquire::Check-Valid-Until=false install \
    --no-install-recommends --yes \
    linux-headers-$ARCH build-essential alien expect
debuerreotype-apt-get $WD/chroot --yes --purge autoremove
debuerreotype-apt-get $WD/chroot --yes clean

# Using a "fake" uname command to get the container kernel version
mv $WD/chroot/usr/bin/uname $WD/chroot/usr/bin/uname.old
cp -p $WD/chroot/opt/luna/fake_uname.sh $WD/chroot/usr/bin/uname

# Extract the Luna HSM Client package
debuerreotype-chroot $WD/chroot tar -xvf $(ls -1 $WD/chroot/opt/luna/*.tar | sed 's,'"${WD}/chroot/"',,') --directory /opt/luna/ 

# Installation of the Thales Luna USB HSM 7 and Luna SDK (PKCS11)
debuerreotype-chroot $WD/chroot bash -c "echo y | $(find $WD/chroot/opt/luna/ -iname install.sh | sed 's,'"${WD}/chroot/"',./,') -p usb -c sdk"

# Restoring the original uname command
mv -f $WD/chroot/usr/bin/uname.old $WD/chroot/usr/bin/uname

# END
