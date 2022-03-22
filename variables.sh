#!/bin/bash
# Configuration for creation of the ISO image. This script is executed by
# create-iso.sh

set -x   # Print each command before executing it
set -e   # Exit immediately should a command fail
set -u   # Treat unset variables as an error and exit immediately

export RELEASE=0.4.0   			# Release version number
export DATE=20220120   			# Timestamp to use for version packages (`date +%Y%m%d`)
export DIST=bullseye   			# Debian distribution to base image on
export ARCH=amd64      			# Target architecture
export SHASUM="8105b885b176741d25ef9d391c6a302aed3f6c916093a621a865cb90d560774f  -" # ISO image SHA-256 
export SOURCE_DATE_EPOCH="$(date --utc --date="$DATE" +%s)" # defined by reproducible-builds.org
export WD=/opt/coen-${RELEASE}	       # Working directory to create the image
export ISONAME=${WD}-${ARCH}.iso       # Final name of the ISO image
export TOOL_DIR=/tools                 # Location to install the tools
export HSM_DIR=/hsm                    # Location of the HSM support docs/tools
export HOOK_DIR=$TOOL_DIR/hooks        # Hooks
export PACKAGE_DIR=$TOOL_DIR/packages  # Packages
