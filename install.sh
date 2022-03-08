#!/bin/bash

# install basic packages
apt-get -y update \
    && apt-get -y dist-upgrade \
    && apt-get -y install sudo bash nano curl
    
# install stubby
apt-get -y update \
    && apt-get -y install stubby

# clean stubby config
mkdir -p /etc/stubby \
    && rm -f /etc/stubby/stubby.yml

# install cloudflared
mkdir -p /tmp \
    && cd /tmp
if [[ ${TARGETPLATFORM} =~ "arm64" ]]
then
    curl -sL https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64.deb -o /tmp/cloudflared.deb
    dpkg --add-architecture arm64
    echo "$(date "+%d.%m.%Y %T") Added cloudflared for ${TARGETPLATFORM}" >> /build.info
elif [[ ${TARGETPLATFORM} =~ "amd64" ]]
then 
    curl -sL https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb -o /tmp/cloudflared.deb
    dpkg --add-architecture amd64
    echo "$(date "+%d.%m.%Y %T") Added cloudflared for ${TARGETPLATFORM}" >> /build.info
elif [[ ${TARGETPLATFORM} =~ "386" ]]
then
    curl -sL https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-386.deb -o /tmp/cloudflared.deb
    dpkg --add-architecture 386
    echo "$(date "+%d.%m.%Y %T") Added cloudflared for ${TARGETPLATFORM}" >> /build.info
elif [[ ${TARGETPLATFORM} =~ 'arm/v7' ]]
then
    curl -sL https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm.deb -o /tmp/cloudflared.deb
    dpkg --add-architecture arm
    echo "$(date "+%d.%m.%Y %T") Added cloudflared for ${TARGETPLATFORM}" >> /build.info
#elif [[ ${TARGETPLATFORM} =~ 'arm/v6' ]]
#then
#    curl -sL https://hobin.ca/cloudflared/releases/2022.3.1/cloudflared_2022.3.1_arm.deb -o /tmp/cloudflared.deb
else 
    echo "$(date "+%d.%m.%Y %T") Unsupported platform - cloudflared not added" >> /build.info
fi
apt install /tmp/cloudflared.deb \
    && rm -f /tmp/cloudflared.deb \
    && useradd -s /usr/sbin/nologin -r -M cloudflared \
    && chown cloudflared:cloudflared /usr/local/bin/cloudflared

# clean cloudflared config
mkdir -p /etc/cloudflared \
    && rm -f /etc/cloudflared/config.yml

# clean up
apt-get -y autoremove \
    && apt-get -y autoclean \
    && apt-get -y clean \
    && rm -fr /tmp/* /var/tmp/* /var/lib/apt/lists/*
