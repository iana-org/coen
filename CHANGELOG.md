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