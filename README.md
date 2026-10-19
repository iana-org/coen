# Ceremony Operating ENvironment (COEN)<!-- omit in toc -->

COEN is a live operating system consisting of:

- A custom Debian GNU/Linux live system
- [Key Management Tools](https://github.com/iana-org/dnssec-keytools) 
- The Thales Luna USB HSM 7 PKCS#11 library and GemEngine
- Assorted utilities
- A minimized Xfce Desktop Environment

## Table of Contents<!-- omit in toc -->
- [Reproducible COEN ISO image to enhance Root Zone DNSSEC Key Signing Key ceremony trustworthiness](#reproducible-coen-iso-image-to-enhance-root-zone-dnssec-key-signing-key-ceremony-trustworthiness)
  - [What are reproducible builds?](#what-are-reproducible-builds)
- [Acknowledgments](#acknowledgments)
- [Requirements for building the COEN ISO image](#requirements-for-building-the-coen-iso-image)
  - [Disabling SELinux](#disabling-selinux)
- [Building the COEN ISO image](#building-the-coen-iso-image)
- [Tested Platforms](#tested-platforms)


## Reproducible COEN ISO image to enhance Root Zone DNSSEC Key Signing Key ceremony trustworthiness

The **reproducible** COEN build process is designed to generate an ISO image with the same cryptographic hash when built using the specified inputs and build requirements. This provides a verifiable process for generating the software environment used during DNSSEC Key Signing Key (KSK) ceremonies.

### What are reproducible builds?

Quoted from https://reproducible-builds.org

> Reproducible builds are a set of software development practices that create an independently-verifiable path from source to binary code.

> The motivation behind the **Reproducible Builds** project is therefore to allow verification that no vulnerabilities or backdoors have been introduced during this compilation process. By promising identical results are always generated from a given source, this allows multiple third parties to come to a consensus on a "correct" result, highlighting any deviations as suspect and worthy of scrutiny.

## Acknowledgments

This project is made possible by:
- The [Reproducible Builds](https://reproducible-builds.org/) project
- [Debian](https://www.debian.org/), providing a reproducible operating system
- [Debuerreotype](https://github.com/debuerreotype/debuerreotype), a reproducible, snapshot-based Debian root filesystem builder ([License](https://github.com/debuerreotype/debuerreotype/blob/master/LICENSE))
- [The Amnesic Incognito Live System](https://tails.boum.org/index.en.html) ([License](https://tails.boum.org/doc/about/license/index.en.html))

## Requirements for building the COEN ISO image

> **Warning**: Generating a reproducible COEN ISO with a matching hash requires running a highly privileged Docker or Podman container and relaxing certain container and host operating system security protections. Consequently, the build should be performed only in a suitable, isolated environment.

To build the COEN ISO image, the following are required:

* An x86-64 (amd64) execution environment. COEN targets this architecture because the laptops used during Root Zone KSK ceremonies are x86-64 systems, and COEN is executed on those systems. The build may run natively on an x86-64 host or in an x86-64 virtualized or emulated environment
* [Docker](https://www.docker.com/) or [Podman](https://podman.io/)
* When using Podman, it must run in **rootful mode**. Rootless Podman does not produce a COEN ISO matching the expected SHA-256 hash. Run the build as `root` or use `sudo`, for example: `sudo make podman-all`
* The build container must run with `--privileged`, which is required during ISO generation for operations including mounting filesystems, creating device nodes, and using `chroot` to construct the new root filesystem
* On systems using SELinux, completely disable SELinux rather than operating in **permissive mode**. During testing, running the container with `--privileged` or disabling SELinux labeling for the container was not sufficient to generate an ISO matching the expected hash. SELinux had to be disabled on the host and the system rebooted before ISO generation. Builds performed with SELinux enabled produced benign differences, but those differences resulted in a different ISO hash

### Disabling SELinux

If you are running a Red Hat-based distribution, including RHEL, CentOS, and Fedora, SELinux is likely installed.

Execute `sestatus` and check the output for the current SELinux mode.

If **Current mode** reports **enforcing** or **permissive**, SELinux is enabled. In enforcing mode, SELinux policies are enforced. In permissive mode, policy violations are logged but not enforced.

> **Note**: Disabling SELinux also prevents SELinux file contexts from being maintained while it is disabled. Re-enabling SELinux may require filesystem relabeling.

To disable SELinux:

- Edit `/etc/sysconfig/selinux` or `/etc/selinux/config`, depending on your distribution
- Set the `SELINUX` parameter to `disabled`
- Reboot the machine for the change to take effect
- Verify the SELinux status using `sestatus`

## Building the COEN ISO image

Run `make` to see the available execution options.

To build the COEN ISO image using Docker:

```sh
make all
```

To build using Podman (rootful mode):

```sh
sudo make podman-all
```

The build process creates a container image using Docker or Podman. A container then executes the `create-iso.sh` Bash script to generate the COEN ISO image. If the build succeeds and the resulting ISO matches the expected SHA-256 hash, the ISO is copied to the host directory.

If permission errors occur when using Docker as a non-root user, verify the Docker permissions and configuration for your environment.

The final hash should match the following:

```
SHA-256:    d11996407e9a64cc8bdbf7544bd95c2977c4b74717527a38c5508591abb769f3
PGP Words:  stairway bottomless prefer Dakota locale newsletter flytrap revolver obtuse suspicious virus equation dragnet supportive escape certify involve reproduce seabird determine banjo enrollment keyboard consulting solo embezzle music miracle rhythm processor gazelle vertigo
```

## Tested Platforms

Testing has been performed in the following environments:

|      OS      |             Architecture             |           Docker           |     Podman      | SELinux  | AppArmor |
| :----------: | :----------------------------------: | :------------------------: | :-------------: | :------: | :------: |
| Debian 13.7  |                x86-64                |   29.9.0, build f415da8    |        -        |    -     | Enabled  |
|  macOS 27.0  | ARM64 host / x86-64 Colima VM (QEMU) | 29.8.1, build 4a63305d74   |        -        |    -     |    -     |
|   RHEL 9.8   |          x86-64 VM (VMware)          |             -              | 5.8.2 (rootful) | Disabled |    -     |
