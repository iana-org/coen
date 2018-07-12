# Ceremony Operating ENvironment (COEN)

COEN is a live operating system consisting of:

- A custom Debian GNU/Linux Live CD
- The [Key Management Tools](https://github.com/iana-org/dnssec-keytools)
- The AEP Keyper PKCS#11 provider
- Assorted utilities.

## Reproducible ISO image to make The Root Zone DNSSEC Key Signing Key Ceremony System more Trustworthy

This **Reproducible** ISO image provide a verifiable process to obtain the same
hash every time at build the ISO image to increase the confidence in the DNSSEC Key
Signing Key (KSK) for the Root Zone.

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
git clone https://github.com/iana-org/coen && \
cd coen && \
make all
```
* If you have a error executing `make all` as a non-root user, try to
execute `sudo make all`.

This will build a docker image with the proper environment to build the
ISO. Then will run a container executing a bash script to build the ISO and
if the build succeeded it will copy the resulting ISO into the host directory.

You can execute `make` command to see more options.

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
Please send us an issue report at https://github.com/iana-org/coen attaching the
diffoscope.txt file.
