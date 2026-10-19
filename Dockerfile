FROM debian:trixie-20260713-slim@sha256:9bb8a3626890e084ab54e888fdd7c4b6d2f119071cd4c5dc5fecb4d73062aa5f

ENV DEBIAN_FRONTEND=noninteractive

COPY SHA256SUMS .
COPY create-iso.sh .
COPY tools/ /tools/
COPY variables.sh .

RUN sha256sum -c SHA256SUMS

RUN . ./variables.sh && \
    rm -f /etc/apt/sources.list.d/debian.sources && \
    rm -f /etc/apt/sources.list && \
    echo "deb http://snapshot.debian.org/archive/debian/$(date --date "$DATE" '+%Y%m%dT%H%M%SZ') "$DIST" main" >> /etc/apt/sources.list && \
    echo "deb http://snapshot.debian.org/archive/debian/$(date --date "$DATE" '+%Y%m%dT%H%M%SZ') "$DIST"-updates main" >> /etc/apt/sources.list && \
    echo "deb http://snapshot.debian.org/archive/debian-security/$(date --date "$DATE" '+%Y%m%dT%H%M%SZ') "$DIST"-security main" >> /etc/apt/sources.list 
   
RUN apt-get update -o Acquire::Check-Valid-Until=false

RUN mkdir -p /var/cache/apt/archives/ && \
    cp /tools/archives-env/*.deb /var/cache/apt/archives/

RUN apt-get install -o Acquire::Check-Valid-Until=false --no-install-recommends --yes \
    grub-common mtools \
    liblzo2-2 xorriso debootstrap debuerreotype locales squashfs-tools
    
RUN rm -rf /var/lib/apt/lists/* \
    && localedef -i en_US -c -f UTF-8 en_US.UTF-8
ENV LANG=en_US.UTF-8

CMD ["/create-iso.sh"]
