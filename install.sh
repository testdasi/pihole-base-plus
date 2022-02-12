#!/bin/bash

# install basic packages
apt-get -y update \
    && apt-get -y dist-upgrade \
    && apt-get -y install sudo bash nano
    
# install stubby
apt-get -y update \
    && apt-get -y install stubby

# clean stubby config
mkdir -p /etc/stubby \
    && rm -f /etc/stubby/stubby.yml

# install cloudflared
if [[ ${TARGETPLATFORM} =~ "arm" ]]
then 
    cd /tmp \
    && wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm.deb \
    && apt install ./cloudflared-linux-arm.deb \
    && rm -f ./cloudflared-linux-arm.deb \
    && echo "Cloudflared installed for arm due to tag ${TAG}"
else 
    cd /tmp \
    && wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb \
    && apt install ./cloudflared-linux-amd64.deb \
    && rm -f ./cloudflared-linux-amd64.deb \
    && echo "Cloudflared installed for amd64 due to tag ${TAG}"
fi
useradd -s /usr/sbin/nologin -r -M cloudflared \
    && chown cloudflared:cloudflared /usr/local/bin/cloudflared
    
# clean cloudflared config
mkdir -p /etc/cloudflared \
    && rm -f /etc/cloudflared/config.yml

# clean up
apt-get -y autoremove \
    && apt-get -y autoclean \
    && apt-get -y clean \
    && rm -fr /tmp/* /var/tmp/* /var/lib/apt/lists/*
