FROM debian:bookworm-20240701-slim@sha256:f528891ab1aa484bf7233dbcc84f3c806c3e427571d75510a9d74bb5ec535b33

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
	&& localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG=en_US.utf8

CMD ["/create-iso.sh"]
