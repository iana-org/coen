# Ceremony Operating ENvironment (COEN)

This is Verkada's forked version of ([coen](https://https://github.com/iana-org/coen)).

Verkada's COEN is a minimal live operating system consisting of:

- A custom Debian 11 GNU/Linux Live CD running XFCE
- Thales Luna USB HSM documentation, drivers, and utilities
- Assorted utilities and whatnot

The basic idea is that you clone this repository and run 'make all'.  This generates
a Docker container, and from within the container, another script runs which
creates a root filesystem with a minimal Debian 11 operating system + HSM utilities,
then packages all of that up into a bootable ISO image.

You then burn the ISO image to CD/DVD/BD, and use that Live CD to boot the code signing
computer in the airgapped Verkada vault.

## Reproducible ISO image to make the OS generation process more trustworthy

This **Reproducible** ISO image provide a verifiable process to obtain the same
hash every time at build.  The generated OS will also verify the same hash and abort
boot if the hash is different.  This protects us against unwanted or unknown upstream
changes.

The custom Live image also checks which drivers are loaded, which devices are connected,
and what the firmware version of the HSM is.  If anything is found to be out of
specification then the system will alert the user and halt.  This is to protect us against
signing computer implants, unwarranted software modifications, etc.

### What are reproducible builds?

Quoted from https://reproducible-builds.org

> Reproducible builds are a set of software development practices that create a
verifiable path from human readable source code to the binary code used by
computers.
>
> Most aspects of software verification are done on source code, as that is what
humans can reasonably understand. But most of the time, computers require
software to be first built into a long string of numbers to be used. With
reproducible builds, multiple parties can redo this process independently and
ensure they all get exactly the same result. We can thus gain confidence that a
distributed binary code is indeed coming from a given source code.

## Acknowledgments

This project cannot be possible without:
- The [Reproducible Builds](https://reproducible-builds.org/) project
- [Debian as trust anchor](https://wiki.debian.org/ReproducibleBuilds)
- [Debuerreotype](https://github.com/debuerreotype/debuerreotype) a reproducible, snapshot-based Debian rootfs builder ([License](https://github.com/debuerreotype/debuerreotype/blob/master/LICENSE))
- (The Amnesic Incognito Live System)[https://tails.boum.org/index.en.html] ([License](https://tails.boum.org/doc/about/license/index.en.html))

## Requirements for building the ISO image

Building the ISO image requires:

* [Docker](https://www.docker.com/). The recommended Docker version is 18.03.
* SELinux to be disabled. SELinux must be completely disabled rather than with **permissive mode** since the behave is differently.

### Disabling SELinux

If you are running a Red Hat based distribution, including RHEL, CentOS and
Fedora, you will probably have the SELinux security module installed.

To check your SELinux mode, run `sestatus` and check the output.

If you see **enforcing** or **permissive** on *"Current mode"*, SELinux is
enabled and enforcing rules or is enable and log rather than enforce errors.

> **Warning** before proceeding with this, disabling SELinux also disables the
generation of file contexts so an entire system relabeling is needed afterwards.

To disable SELinux:

- Edit `/etc/sysconfig/selinux` or `/etc/selinux/config` depending of your distro
- Set the `SELINUX` parameter to `disabled`
- For the changes to take effect, you need to **reboot** the machine, since
SELinux is running within the kernel
- Check the status of SELinux using `sestatus` command

## Building the ISO image

Execute the following commands to build the ISO image:

```
git clone https://github.com/verkada/coen && \
cd coen && \
make all
```
This will build a docker image with the proper environment to build the
ISO. Then will run a container executing a bash script to build the ISO and
if the build succeeded it will copy the resulting ISO into the host directory.

You can execute `make` command to see more options.

## Testing the ISO image

Before burning the ISO to CD/DVD/BD, you might want to test it locally.  The
easiest and fastest way to do that is to fire it up in QEMU:

```
qemu-system-x86_64 -boot d -cdrom coen-0.4.0-amd64.iso -m 768 -device qemu-xhci,id=xhci
```

Note that the above loads the image using ISOLINUX.  You'll probably also want
to check that it works for UEFI systems (most PCs these days).  Do that with this:

```
sudo apt-get install ovmf
qemu-system-x86_64 -boot d -cdrom coen-0.4.0-amd64.iso -bios /usr/share/ovmf/OVMF.fd -m 768 -device qemu-xhci,id=xhci
```

General things to check for:
* Errors in dmesg
* Failed startup messages in systemctl

Please note that QEMU is a good way to test basics like "Does the system boot?",
"Are the right utilities installed?", "Are user permissions setup correctly?", but
it cannot check the actual HSM hardware.  Some testing has to be done with real hardware.

## Contributing

### If the build failed

Please send us an issue report at https://github.com/iana-org/coen with the error
that is displayed in your terminal window.

### If the reproduction succeeded

Congrats for successfully reproducing the ISO image!

You can compute the SHA-256 checksum of the resulting ISO image by yourself:

```
sha256sum coen-0.4.0-amd64.iso
```
or
```
shasum -a 256 coen-0.4.0-amd64.iso
```

Then, comparing it with the following checksum:

```
8105b885b176741d25ef9d391c6a302aed3f6c916093a621a865cb90d560774f  coen-0.4.0-amd64.iso
```



### If the reproduction failed

Please help us to improve it. You can install `diffoscope` https://diffoscope.org/
and download the image from:
https://github.com/iana-org/coen/releases/tag/v0.4.0-20180311
and then compare it with your image executing the following command:

```
diffoscope \
  --text diffoscope.txt \
  path/to/public/coen-0.4.0-amd64.iso \
  path/to/your/coen-0.4.0-amd64.iso
```

## Debugging Techniques

You can try building two different ISOs.  When the hashes between the two are
different, look into the image as thus:

The most likely differrence is in the root file system. Loopback mount the before
and after image, and do a filesystem dump of squashFS:

```
make all
mv coen-0.4.0-amd64.iso before.iso
make all
mv coen-0.4.0-amd64.iso after.iso

mkdir /mnt/iso.before
mkdir /mnt/iso.after
mount -o loop before.iso /mnt/iso.before/
mount -o loop after.iso /mnt/iso.after

unsquashfs -ll /mnt/iso.before/live/filesystem.squashfs > /tmp/before
unsquashfs -ll /mnt/iso.after/live/filesystem.squashfs > /tmp/after

diff /tmp/before /tmp/after
```

This helps you find differences in files that are differently sized or
differently named.  A lot of libraries/utilities create randomly-named
cache files or UUIDs or similar which can just be deleted.

When you get to a place where the hashes still differ and all of the file
sizes of the before and after root FS are the same and a diff is the same
then it must be the content that differs.  Use sha256sum to sort it out:

```
mkdir /mnt/squash.before
mkdir /mnt/squash.after
mount /mnt/iso.before/live/filesystem.squashfs /mnt/squash.before
mount /mnt/iso.after/live/filesystem.squashfs /mnt/squash.after

find /mnt/squash.before -type f -exec sha256sum {} \; > /tmp/hashes.before
find /mnt/squash.after -type f -exec sha256sum {} \; > /tmp/hashes.after

diff /tmp/hashes.before /tmp/hashes.after
```

If you still get a match on the individual file hashes but the ISOs themselves
hash different hashes, it's time to bust out diffoscope and/or your favorite
hexdump tool and figure out what and where in the ISO image the difference lies.

Please send us an issue report at https://github.com/iana-org/coen attaching the
diffoscope.txt file.

### Work to do

- [ ] Figure out a better package host than snapshot.debian.org.  This one is rate-limited so you can't pull packages with apt-fast, which increases ISO container build time.
- [ ] Better handling for download failures.  Right now a single download failure kills the process--super annoying when you have a build in process and you have to go to a meeting.
- [x] Add UEFI support, to allow for stuff to work on a modern PC.  Original COEN only supported ISOLINUX (non-UEFI) boot.
- [ ] Blacklist USB mass storage.  This will be added at the end, once the project is stabilized.
- [ ] Check devices (PCI & USB & HSM) plugged into the system at startup and abort if foreign devices detected.
