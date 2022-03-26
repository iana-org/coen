FROM --platform=linux/amd64 debian:11.2-slim@sha256:125f346eac7055d8e1de1b036b1bd39781be5bad3d36417c109729d71af0cd73

ENV DEBIAN_FRONTEND noninteractive

COPY create-iso.sh .
COPY uname.sh .
COPY variables.sh .
COPY SHA256SUMS .
COPY tools/ /tools/
COPY hsm/ /hsm/

#RUN sha256sum -c SHA256SUMS

RUN . ./variables.sh && \
    rm -f /etc/apt/sources.list && \
    echo "deb http://snapshot.debian.org/archive/debian/$(date --date "$DATE" '+%Y%m%dT%H%M%SZ') $DIST main" >> /etc/apt/sources.list && \
    echo "deb http://snapshot.debian.org/archive/debian/$(date --date "$DATE" '+%Y%m%dT%H%M%SZ') "$DIST"-updates main" >> /etc/apt/sources.list && \
    echo "deb http://snapshot.debian.org/archive/debian-security/$(date --date "$DATE" '+%Y%m%dT%H%M%SZ') "$DIST"-security/updates main" >> /etc/apt/sources.list

RUN apt-get update -o Acquire::Check-Valid-Until=false && \
    apt-get install -o Acquire::Check-Valid-Until=false --no-install-recommends --yes gpg wget ca-certificates aria2

RUN wget https://github.com/ilikenwf/apt-fast/archive/refs/tags/1.9.12.tar.gz && \
    tar zxvf 1.9.12.tar.gz && \
    cp apt-fast-1.9.12/apt-fast /usr/local/sbin/ && \
    chmod +x /usr/local/sbin/apt-fast && \
    cp apt-fast-1.9.12/apt-fast.conf /etc


RUN apt-get update -o Acquire::Check-Valid-Until=false && \
    apt-get install -o Acquire::Check-Valid-Until=false --no-install-recommends --yes \
    docker \
    liblzo2-2 \
    xorriso \
    debootstrap \
    locales \
    squashfs-tools \
    isolinux \
    syslinux-efi \
    grub-pc-bin \
    grub-efi-amd64-bin \    
    mtools \
    dosfstools \
    debuerreotype \
    vim \
    strace && \
    sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen && \
    locale-gen en_US.UTF-8
 

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN dpkg-reconfigure locales

#RUN dpkg -i /tools/squashfs-tools_4.4-2+deb11u2_amd64.deb && \
#    dpkg -i /tools/debuerreotype_0.9-1_all.deb

#CMD ["/create-iso.sh"]
