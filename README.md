# Ceremony Operating ENvironment (COEN)<!-- omit in toc -->

COEN is a live operating system consisting of:

- A custom Debian GNU/Linux Live CD
- [Key Management Tools: Legacy](https://github.com/iana-org/dnssec-keytools-legacy)
- [Key Management Tools](https://github.com/iana-org/dnssec-keytools) 
- The AEP Keyper PKCS#11 library
- The Thales Luna USB HSM 7 PKCS#11 library
- Assorted utilities
- Minimized Xfce Desktop Environment

## Table of Contents<!-- omit in toc -->
- [Reproducible COEN ISO image to enhance Root Zone DNSSEC Key Signing Key ceremony trustworthiness](#reproducible-coen-iso-image-to-enhance-root-zone-dnssec-key-signing-key-ceremony-trustworthiness)
  - [What are reproducible builds?](#what-are-reproducible-builds)
- [Acknowledgments](#acknowledgments)
- [Requirements for building the COEN ISO image](#requirements-for-building-the-coen-iso-image)
  - [Disabling SELinux](#disabling-selinux)
- [Building the COEN ISO image](#building-the-coen-iso-image)
- [Tested Platforms](#tested-platforms)


## Reproducible COEN ISO image to enhance Root Zone DNSSEC Key Signing Key ceremony trustworthiness

The **reproducible** COEN ISO image provides a verifiable process to generate the same hash any time the COEN ISO image is built, which consequently increases trustworthiness in the DNSSEC Key Signing Key (KSK).

### What are reproducible builds?

Quoted from https://reproducible-builds.org

> Reproducible builds are a set of software development practices that create an independently-verifiable path from source to binary code.

> The motivation behind the **Reproducible Builds** project is therefore to allow verification that no vulnerabilities or backdoors have been introduced during this compilation process. By promising identical results are always generated from a given source, this allows multiple third parties to come to a consensus on a "correct" result, highlighting any deviations as suspect and worthy of scrutiny.

## Acknowledgments

This project is made possibly by:
- The [Reproducible Builds](https://reproducible-builds.org/) project
- [Debian serving as trust anchor](https://www.debian.org/)
- [Debuerreotype](https://github.com/debuerreotype/debuerreotype) a reproducible, snapshot-based Debian rootfs builder ([License](https://github.com/debuerreotype/debuerreotype/blob/master/LICENSE))
- [The Amnesic Incognito Live System](https://tails.boum.org/index.en.html) ([License](https://tails.boum.org/doc/about/license/index.en.html))

## Requirements for building the COEN ISO image

> **Warning**: In order to generate a reproducible COEN ISO with a matching hash, Docker/Podman requires administrator privileges, and suppressing container and operating system security protections. Consequently, testing should occur in a suitable environment.

To build the COEN ISO image:

* Use [Docker](https://www.docker.com/) (recommended) or alternatively [Podman](https://podman.io/)
* Execute commands as administrator, root, or with `sudo`  
* Execute container with full capabilities `--privileged` which is required during ISO generation to mount/share, create device nodes, chroot into the new rootfs, and disable security kernel protections e.g. AppArmor and SELinux
* Completely disable SELinux rather than operating with **permissive mode** because the generated image will not be reproducible otherwise. In addition, `--privilege` mode reportedly disables SELinux with `--security-opt label=disable`, but in testing, without manually disabling SELinux prior to ISO generation including a restart to reload the kernel, the resulting ISO will not match the hash. The differences with SELinux enabled are benign, but obviously result in a different hash

### Disabling SELinux

If you are running a Red Hat based distribution, including RHEL, CentOS, and Fedora, it is likely the SELinux security module is installed.

Execute `sestatus` and check the output for the current SELinux mode.

If you see **enforcing** or **permissive** for *"Current mode"*, SELinux is
enabled and enforcing rules or is enabled and logging rather than enforcing errors.

> **Note**: before proceeding, be aware disabling SELinux also disables the
generation of file contexts, so an entire system relabeling is required if SELinux is enabled again.

To disable SELinux:

- Edit `/etc/sysconfig/selinux` or `/etc/selinux/config` depending on your distribution
- Set the `SELinux` parameter to `disabled`
- For the changes to take effect, you need to **reboot** the machine, since
SELinux is running within the kernel
- Check the status of SELinux using the `sestatus` command

## Building the COEN ISO image

Run `make` to see the execution options.

Running `make all` or `make podman-all` will build a container image in Docker or Podman. Then, a container will execute a bash script to build the COEN ISO, and if the build succeeds, the resulting COEN ISO will be copied into the host directory.

If permission errors are encountered executing `make all` or `make podman-all` as a non-root user, try `sudo make all` or `sudo make podman-all`

Final hash result should match with the following:

```
SHA-256:    2363d9c484e919b58bd45f413dedaed364712d72b3b7858c0fec5e3c529390d8
PGP Words:  blowtorch Galveston sugar reproduce mural ultimate bedlamp positive obtuse souvenir eyetooth decadence commence unify robust sociable flytrap hideaway button holiness scallion processor music megaton artist unicorn eyeglass crossover Dupont molasses peachy stupendous
```

## Tested Platforms

Testing has been performed in the following environments:

|          OS          |            Docker            | Podman | SELinux  | AppArmor |
| :------------------: | :--------------------------: | :----: | :------: | :------: |
| Debian 11.6 bullseye |    23.0.1, build a5ee5b1     |   -    |    -     | Enabled  |
|      Arch Linux      |   23.0.1, build a5ee5b1dfc   |   -    |    -     |    -     |
|      Fedora 37       |    23.0.1, build a5ee5b1     | 4.4.2  | Disabled |    -     |
|    AlmaLinux 9.1     |    23.0.1, build a5ee5b1     | 4.2.0  | Disabled |    -     |
|   CentOS 7.9.2009    |    23.0.1, build a5ee5b1     |   -    | Disabled |    -     |
| macOS Sonoma 14.3.1  |   25.0.3, build 4debf41      |   -    |    -     |    -     |
| openSUSE Tumbleweed  | 20.10.23-ce, build 6051f1429 |   -    |    -     | Enabled  |
|      Windows 10      |   20.10.22, build 32ac30b    |   -    |    -     |    -     |
|  Ubuntu 22.04.2 LTS  |  20.10.17, build 100c70180f  |   -    |    -     | Enabled  |