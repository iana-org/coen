#!/bin/bash
# Configuration for creating the ISO image. This script is executed by create-iso.sh

set -x   # Print each command before executing it
set -e   # Exit immediately should a command fail
set -u   # Treat unset variables as an error and exit immediately

export RELEASE=1.0.0			        # Release version number
export DATE=20230109			        # Timestamp to use for version packages (`date +%Y%m%d`)
export LOCALE_LC_ALL=POSIX              # Current OS locale setting
export DIST=bullseye			        # Debian distribution base image
export DIST_ADD=bookworm		        # Debian additional distribution
export ARCH=amd64			            # Target architecture
export SOURCE_DATE_EPOCH="$(date --utc --date="$DATE" +%s)" # defined by reproducible-builds.org
export WD=/opt/coen-${RELEASE}          # Working directory to create the image
export ISONAME=${WD}-${ARCH}.iso        # Final name of the ISO image
export TOOL_DIR=/tools                  # Location to install the tools
export HOOK_DIR=$TOOL_DIR/hooks         # Hooks
export PACKAGE_DIR=$TOOL_DIR/packages   # Packages
export DISTRO_DIR=$TOOL_DIR/archives-distro # Distro packages
export FONTC_DIR=$TOOL_DIR/archives-fontc   # Fontconfig packages
export ROOTFS_INIT_SHASUM="33e7da7c1bdc7f9cae9576b47c8aa0a976f00203df2c3c16be79eb62c9f99500  -" # rootfs-init SHA-256
export INITRD_FINAL_SHASUM="5d295660190d94cb4dafbe60ae38838a3a2bf3ad70f761a23addaed3b0711c01  -" # initrd-img SHA-256
export ROOTFS_FINAL_SHASUM="51625886cbd838830e9374f3f37554e75e54ea706a7b51b81f20a58bd8c18331  -" # rootfs-final SHA-256
export SQUASHFS_SHASUM="ac3679167c8037576f892f385e624a57eda4cf9b740585d44cc58297f8cdd987  -" # squashfs SHA-256
export ISO_SHASUM="405d7c76c114feb93fcc5345e13850e59d86341a08161207d8eb8c395410c13a  -" # ISO image SHA-256