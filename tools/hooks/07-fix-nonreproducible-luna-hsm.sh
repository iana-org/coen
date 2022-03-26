#!/bin/bash
# Fixing non-reproducible files

set -x   # Print each command before executing it
set -e   # Exit immediately should a command fail
set -u   # Treat unset variables as an error and exit immediately

# Installing the Luna HSM driver causes it to compile from source the driver, then
# package the driver into RPM format and install for future reference.  This is
# done by Thales' installed and outside of our control.  The files are non-reproducible
# as they contain date/time stamps and have different SHAs, even though the compiled
# code is exactly the same.
#
# So, here we take the pre-compiled version and replace the one in the tree with that.
#
# It's rickety and sensitive to future HSM upgrades but those happen 1-2x a year so it's
# manageable.

pwd
cp tools/hooks/uhd-10.4.1-7.x86_64.rpm $WD/chroot/usr/safenet/lunaclient/g5driver/x86_64/
cp tools/hooks/g7-10.4.1-7.x86_64.rpm  $WD/chroot/usr/safenet/lunaclient/g7driver/x86_64/

# END
