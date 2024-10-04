#!/bin/bash

set -x   # Print each command before executing it
set -e   # Exit immediately should a command fail
set -u   # Treat unset variables as an error and exit immediately

# Installs KSK software and XFCE customization packages
cat $PACKAGE_DIR/ksk-tools-2-part_* > $WD/chroot/tmp/ksk-tools-2.0.0coen_amd64.deb
cp $PACKAGE_DIR/*.deb $WD/chroot/tmp/
debuerreotype-chroot $WD/chroot dpkg -i -R /tmp/
rm -f $WD/chroot/tmp/*.deb

# dnssec-keytools
debuerreotype-chroot $WD/chroot tar -zxf /opt/kskm.tgz --directory /opt/
rm -f $WD/chroot/opt/kskm.tgz*

# Activate Python environment
echo "source /opt/kskm/bin/activate" >> $WD/chroot/root/.bashrc

# Thales Luna USB HSM 7 
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
debuerreotype-chroot $WD/chroot tar -xf $(ls -1 $WD/chroot/opt/luna/client/*.tar | sed 's,'"${WD}/chroot/"',,') --directory /opt/luna/ 

# Installation of the Thales Luna USB HSM 7 and Luna SDK (PKCS11)
debuerreotype-chroot $WD/chroot bash -c "echo y | $(find $WD/chroot/opt/luna/ -iname install.sh | sed 's,'"${WD}/chroot/"',./,') -p usb -c sdk"

# Restoring the original uname command
mv -f $WD/chroot/usr/bin/uname.old $WD/chroot/usr/bin/uname

# Extract the GemEngine
debuerreotype-chroot $WD/chroot tar -xf $(ls -1 $WD/chroot/opt/luna/engine/*.tar | sed 's,'"${WD}/chroot/"',,') --directory /opt/luna/ 

# Copy gem.so and sautil binaries
cp $WD/chroot/opt/luna/gemengine*/builds/linux/debian/64/3.0/gem.so $WD/chroot/usr/lib/x86_64-linux-gnu/engines-3/
cp $WD/chroot/opt/luna/gemengine*/builds/linux/debian/64/3.0/sautil $WD/chroot/usr/local/bin/

# Add Open GemEngine section to /etc/Chrystoki.conf
cat $WD/chroot/opt/luna/engine/GemEngine.conf >> $WD/chroot/etc/Chrystoki.conf

# Fixing ownership on non-reproducible files
debuerreotype-chroot $WD/chroot chown -R root:root /usr/safenet/lunaclient/

# Clean 
rm -f $WD/chroot/opt/luna/client/*.tar*
rm -f $WD/chroot/opt/luna/engine/*.tar*

# END
