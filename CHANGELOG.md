# [v3.0.0-20260731](https://github.com/iana-org/coen/releases/tag/v3.0.0-20260731) coen-3.0.0-amd64.iso

## Contains

* Release v3.0.0 (for the Acceptance Testing Ceremony)
* Based on Debian 13.6 trixie from [snapshot.debian.org](https://snapshot.debian.org), dated 20260731
* EPOCH=1785456000
* [Key Management Tools](https://github.com/iana-org/dnssec-keytools/tree/test/2026-20260913-dab0d1f), commit `dab0d1f` (2026-09-13)
* Thales Luna Client 10.9.3
* Thales GemEngine 1.6
* Thales Luna documentation dated 2026-09-15
* Assorted utilities
* Minimized Xfce Desktop Environment

## Improvements

* Updated [Key Management Tools](https://github.com/iana-org/dnssec-keytools) for acceptance testing
* Removed all AEP Keyper functionality and legacy dependencies

### Packages 

* Added `zstd` to support the default Debian initramfs compression environment

### Scripts 

* None

### Build Process

* Updated the build process to reconstruct large Debian packages from split files
* Updated LightDM configuration to support automatic root login
* Added a requirement to run Podman in rootful mode to reproduce the expected ISO hash


# [v2.0.1-20240701](https://github.com/iana-org/coen/releases/tag/v2.0.1-20240701) coen-2.0.1-amd64.iso

## Contains

* Release v2.0.1
* Based on Debian 12.6 bookworm from http://snapshot.debian.org date 20240701
* EPOCH=1719792000
* [Key Management Tools: Legacy](https://github.com/iana-org/dnssec-keytools-legacy)
* [Key Management Tools](https://github.com/iana-org/dnssec-keytools)
* AEP Keyper PKCS#11 library
* Thales Luna USB HSM 7 PKCS#11 library and GemEngine
* Assorted utilities
* Minimized Xfce Desktop Environment

## Improvements

* Removed boot option `live-media=removable` for updated laptop hardware support 

### Packages 

* None

### Scripts 

* None

### New Features 

* None


# [v2.0.0-20240701](https://github.com/iana-org/coen/releases/tag/v2.0.0-20240701) coen-2.0.0-amd64.iso

## Contains

* Release v2.0.0
* Based on Debian 12.6 bookworm from http://snapshot.debian.org date 20240701
* EPOCH=1719792000
* [Key Management Tools: Legacy](https://github.com/iana-org/dnssec-keytools-legacy)
* [Key Management Tools](https://github.com/iana-org/dnssec-keytools)
* AEP Keyper PKCS#11 library
* Thales Luna USB HSM 7 PKCS#11 library and GemEngine
* Assorted utilities
* Minimized Xfce Desktop Environment

## Improvements

* Updated [Key Management Tools](https://github.com/iana-org/dnssec-keytools)
* Changed terminal text and background colors for optimized printouts

### Packages 

* Removed exfat-fuse
* Replaced exfat-utils with exfatprogs

### Scripts 

* None

### New Features 

* Added GemEngine


# [v1.1.0-20230109](https://github.com/iana-org/coen/releases/tag/v1.1.0-20230109) coen-1.1.0-amd64.iso

## Contains

* Release v1.1.0
* Based on Debian 11.6 bullseye from http://snapshot.debian.org date 20230109
* EPOCH=1673222400
* [Key Management Tools: Legacy](https://github.com/iana-org/dnssec-keytools-legacy)
* [Key Management Tools](https://github.com/iana-org/dnssec-keytools)
* AEP Keyper PKCS#11 library
* Thales Luna USB HSM 7 PKCS#11 library
* Assorted utilities
* Minimized Xfce Desktop Environment

## Improvements

* Combined all hash verifications into a single file

### Packages 

* Added Thales Luna HSM client package for USB HSM 7 and SDK (PKCS#11)
* Added xfce4-screenshooter to take screenshots
* Added ristretto to view images

### Scripts 

* **copy-hsmfd:** Added verbose option 

### New Features 

* **screencap-verify:** Bash script to take a screenshot, print it, and open it for verification


# [v1.0.0-20230109](https://github.com/iana-org/coen/releases/tag/v1.0.0-20230109) coen-1.0.0-amd64.iso

## Contains

* Release v1.0.0
* Based on Debian 11.6 bullseye from http://snapshot.debian.org date 20230109
* EPOCH=1673222400
* [Key Management Tools: Legacy](https://github.com/iana-org/dnssec-keytools-legacy)
* [Key Management Tools](https://github.com/iana-org/dnssec-keytools)
* AEP Keyper PKCS#11 library
* Assorted utilities
* Minimized Xfce Desktop Environment

## Improvements

* Overall grammar improvements
* COEN v1.0.0 is a hybrid ISO. This allows use with both legacy and modern BIOS boot methods and was tested with CD/DVD, USB Flash, and SD card media
* All packages are reproducible from Debian bullseye, and only fontconfing is from bookworm

### Packages 

* Replaced syslinux by grub-pc-bin and grub-efi-amd64-bin
* Added exfat, unzip, locales, python3, and openssl libraries
* Added xsltproc for xml file comparison

### Scripts 

* **configure-printer:** Deprecation warning message about the use of ppd sent to /dev/null instead of showing in the terminal 
* **hsmfd-hash:** Explicitly indicates that sort uses `LC_COLLATE=POSIX`. Added default copies for printing the HSMFD hash
* **printlog:** Added copies for printing, reduced font size, and added regular expression to remove log timestamps and loglevel for printing


### New Features 

* **print-script:** Bash script to print the terminal commands
* **print-ttyaudit:** Bash script to print the HSM logs 
* **copy-hsmfd:** Bash script to copy HSMFD contents to new flash drives; includes verification via hash comparison


# [v0.4.0-20180311](https://github.com/iana-org/coen/releases/tag/v0.4.0-20180311) coen-0.4.0-amd64.iso

## Contains

* First public release v0.4.0
* Based on Debian 9.4 stretch from http://snapshot.debian.org date 20180311
* EPOCH=1520726400
* [Key Management Tools: Legacy](https://github.com/iana-org/dnssec-keytools-legacy)
* AEP Keyper PKCS#11 provider
* Assorted utilities
* Minimized Xfce Desktop Environment