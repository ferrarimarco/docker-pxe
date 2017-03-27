FROM ubuntu:16.04

# Install the necessary packages
RUN apt-get update \
  && apt-get install -y \
    dnsmasq \
    pxelinux \
    syslinux-common \
    wget

# Stop the dnsmasq service that is automatically started after installing the
# corresponding package
RUN service dnsmasq stop

# Create the TFTP root directory
# Download and extract MemTest86+
ENV MEMTEST_VERSION 5.01
RUN mkdir -p /var/lib/tftpboot \
  && wget http://www.memtest.org/download/$MEMTEST_VERSION/memtest86+-$MEMTEST_VERSION.bin.gz \
  && gzip -d memtest86+-$MEMTEST_VERSION.bin.gz \
  && mkdir -p /var/lib/tftpboot/memtest \
  && mv memtest86+-$MEMTEST_VERSION.bin /var/lib/tftpboot/memtest/memtest86+

# Setup PXE
RUN mkdir -p /var/lib/tftpboot/pxelinux.cfg \
  && echo 'default memtest86\n\
menu title PXE Boot Menu\n\
prompt 1\n\
timeout 15\n\
label memtest86\n\
  menu label Memtest86+\n\
  kernel /memtest/memtest86+' > /var/lib/tftpboot/pxelinux.cfg/default \
  && ln -sf /usr/lib/PXELINUX/pxelinux.0 /var/lib/tftpboot/ \
  && ln -sf /usr/lib/syslinux/modules/bios/ldlinux.c32 /var/lib/tftpboot/

# Setup DNSMASQ
RUN echo '# Disable DNS Server\n\
port=0\n\
\n\
# Enable DHCP logging\n\
log-dhcp\n\
\n\
dhcp-boot=pxelinux.0\n\
\n\
# Provide network boot option called "Network Boot"\n\
pxe-service=x86PC,"Network Boot",pxelinux\n\
\n\
enable-tftp\n\
tftp-root=/var/lib/tftpboot\n\
\n\
# Run as root user\n\
user=root' > /etc/dnsmasq.conf \
   && echo "DNSMASQ_EXCEPT=lo" > /etc/default/dnsmasq

# Start dnsmasq. It picks up default configuration from /etc/dnsmasq.conf and
# /etc/default/dnsmasq plus any command line switch
ENTRYPOINT ["dnsmasq", "--no-daemon"]
CMD ["--dhcp-range=192.168.56.2,proxy"]
