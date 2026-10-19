#!/bin/bash
# Configuration for creating the ISO image. This script is executed by create-iso.sh

set -x   # Print each command before executing it
set -e   # Exit immediately should a command fail
set -u   # Treat unset variables as an error and exit immediately

export RELEASE=3.0.0			        # Release version
export DATE=20260731			        # Date used for the Debian snapshot and package timestamps (`date +%Y%m%d`)
export DIST=trixie  			        # Debian distribution
export GEMENGINE_OPENSSL=3.0            # GemEngine build selection
export LOCALE_LC_ALL=POSIX              # Locale used during ISO generation
export ARCH=amd64			            # Target architecture (x86-64)
export SOURCE_DATE_EPOCH="$(date --utc --date="$DATE" +%s)" # Reproducible build timestamp
export WD=/opt/coen-${RELEASE}          # Working directory to create the image
export ISONAME=${WD}-${ARCH}.iso        # Final name of the ISO image
export TOOL_DIR=/tools                  # Location to install the tools
export HOOK_DIR=$TOOL_DIR/hooks         # Hooks
export PACKAGE_DIR=$TOOL_DIR/packages   # Packages
export DISTRO_DIR=$TOOL_DIR/archives-distro # Distro packages
export DEV_DIR=$TOOL_DIR/archives-dev   # Dev packages
export ISO_SHASUM="d11996407e9a64cc8bdbf7544bd95c2977c4b74717527a38c5508591abb769f3  -" # Expected SHA-256 checksum of the ISO image
