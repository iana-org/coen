#!/bin/bash
# Configuration for creating the ISO image. This script is executed by create-iso.sh

set -x   # Print each command before executing it
set -e   # Exit immediately should a command fail
set -u   # Treat unset variables as an error and exit immediately

export RELEASE=1.1.0			        # Release version number
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
export DEV_DIR=$TOOL_DIR/archives-dev   # Dev packages
export INITRD_FINAL_SHASUM="5d295660190d94cb4dafbe60ae38838a3a2bf3ad70f761a23addaed3b0711c01  -" # initrd-img SHA-256
export SQUASHFS_SHASUM="241d3f12ba547dfd02974caae9e7451dd3e19bc7422aa02f83fa2d8e33ae83f0  -" # squashfs SHA-256
export ISO_SHASUM="2363d9c484e919b58bd45f413dedaed364712d72b3b7858c0fec5e3c529390d8  -" # ISO image SHA-256