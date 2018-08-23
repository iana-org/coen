FROM debian:9.4-slim@sha256:91e111a5c5314bc443be24cf8c0d59f19ffad6b0ea8ef8f54aedd41b8203e3e1

ENV DEBIAN_FRONTEND noninteractive

COPY create-iso.sh .
COPY variables.sh .
COPY SHA256SUMS .
COPY tools/ /tools/

RUN sha256sum -c SHA256SUMS

RUN . ./variables.sh && \
    rm -f /etc/apt/sources.list && \
    echo "deb http://snapshot.debian.org/archive/debian/$(date --date "$DATE" '+%Y%m%dT%H%M%SZ') $DIST main" >> /etc/apt/sources.list && \
    echo "deb http://snapshot.debian.org/archive/debian/$(date --date "$DATE" '+%Y%m%dT%H%M%SZ') "$DIST"-updates main" >> /etc/apt/sources.list && \
    echo "deb http://snapshot.debian.org/archive/debian-security/$(date --date "$DATE" '+%Y%m%dT%H%M%SZ') "$DIST"/updates main" >> /etc/apt/sources.list && \
    echo "APT::Default-Release \"$DIST\";" > /etc/apt/apt.conf && \
    echo "deb http://deb.debian.org/debian testing main" >> /etc/apt/sources.list

RUN apt-get update -o Acquire::Check-Valid-Until=false && \
    apt-get install -o Acquire::Check-Valid-Until=false --no-install-recommends --yes \
    grub-pc-bin grub-efi-ia32-bin grub-efi-amd64-bin mtools=4.0.18-2.1 \
    liblzo2-2 xorriso debootstrap \
    locales && \
    sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen && \
    locale-gen en_US.UTF-8

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN dpkg-reconfigure locales

RUN dpkg -i /tools/squashfs-tools_4.3-3.0tails4_amd64.deb && \
    dpkg -i /tools/debuerreotype_0.7-1_all.deb

CMD ["/create-iso.sh"]
