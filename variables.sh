#!/bin/bash
# Configuration for creating the ISO image. This script is executed by create-iso.sh

set -x   # Print each command before executing it
set -e   # Exit immediately should a command fail
set -u   # Treat unset variables as an error and exit immediately

export RELEASE=2.0.0			        # Release version number
export DATE=20240701			        # Timestamp to use for version packages (`date +%Y%m%d`)
export LOCALE_LC_ALL=POSIX              # Current OS locale setting
export DIST=bookworm			        # Debian distribution base image
export ARCH=amd64			            # Target architecture
export SOURCE_DATE_EPOCH="$(date --utc --date="$DATE" +%s)" # defined by reproducible-builds.org
export WD=/opt/coen-${RELEASE}          # Working directory to create the image
export ISONAME=${WD}-${ARCH}.iso        # Final name of the ISO image
export TOOL_DIR=/tools                  # Location to install the tools
export HOOK_DIR=$TOOL_DIR/hooks         # Hooks
export PACKAGE_DIR=$TOOL_DIR/packages   # Packages
export DISTRO_DIR=$TOOL_DIR/archives-distro # Distro packages
export DEV_DIR=$TOOL_DIR/archives-dev   # Dev packages
export ISO_SHASUM="4d2d61b982550df637102701e73a14f292d51bf98b823fc9724e0d9a8e91cead  -" # ISO image SHA-256
