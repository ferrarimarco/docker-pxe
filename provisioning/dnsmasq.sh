#!/bin/sh

# Install the necessary packages
apt-get update \
  && apt-get install -y \
    dnsmasq \
    pxelinux \
    syslinux-common \
    wget

# Stop the dnsmasq service that is automatically started after installing the
# corresponding package
service dnsmasq stop

# Create the TFTP root directory
mkdir -p /var/lib/tftpboot

# Download and extract MemTest86+
wget http://www.memtest.org/download/5.01/memtest86+-5.01.bin.gz \
  && gzip -dk memtest86+-5.01.bin.gz \
  && mkdir -p /var/lib/tftpboot/memtest \
  && cp memtest86+-5.01.bin /var/lib/tftpboot/memtest/memtest86+-5.01

# Setup PXE
mkdir -p /var/lib/tftpboot/pxelinux.cfg \
  && echo 'default memtest86
prompt 1
timeout 15
label memtest86
  menu label Memtest86+ 5.01
  kernel /memtest/memtest86+-5.01' > /var/lib/tftpboot/pxelinux.cfg/default \
  && ln -sf /usr/lib/PXELINUX/pxelinux.0 /var/lib/tftpboot/ \
  && ln -sf /usr/lib/syslinux/modules/bios/ldlinux.c32 /var/lib/tftpboot/

# Setup DNSMASQ
echo '# Disable DNS Server
port=0

# Enable DHCP logging
log-dhcp

# Respond to PXE requests for the specified network
# run as DHCP proxy
dhcp-range=192.168.0.10,192.168.0.20,255.255.255.0

dhcp-boot=pxelinux.0

# Provide network boot option called "Network Boot"
pxe-service=x86PC,"Network Boot",pxelinux

enable-tftp
tftp-root=/var/lib/tftpboot

# Run as root user
user=root' > /etc/dnsmasq.conf \
   && echo "DNSMASQ_EXCEPT=lo" > /etc/default/dnsmasq

# Start dnsmasq service. It picks up default configuration from
# /etc/dnsmasq.conf and /etc/default/dnsmasq
service dnsmasq start
