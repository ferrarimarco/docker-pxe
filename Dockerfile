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
  && echo '\n\
default ubuntu-16-04-amd64\n\
\n\
MENU WIDTH 80\n\
MENU MARGIN 10\n\
MENU PASSWORDMARGIN 3\n\
MENU ROWS 10\n\
MENU TABMSGROW 15\n\
MENU CMDLINEROW 15\n\
MENU ENDROW 24\n\
MENU PASSWORDROW 11\n\
MENU TIMEOUTROW 16\n\
MENU TITLE Pick Your Path\n\
\n\
menu color title 1;34;49 #eea0a0ff #cc333355 std\n\
menu color sel 7;37;40 #ff000000 #bb9999aa all\n\
menu color border 30;44 #ffffffff #00000000 std\n\
menu color pwdheader 31;47 #eeff1010 #20ffffff std\n\
menu color hotkey 35;40 #90ffff00 #00000000 std\n\
menu color hotsel 35;40 #90000000 #bb9999aa all\n\
menu color timeout_msg 35;40 #90ffffff #00000000 none\n\
menu color timeout 31;47 #eeff1010 #00000000 none\n\
menu title PXE Boot Menu\n\
\n\
prompt 1\n\
timeout 15\n\
\n\
label memtest86\n\
  menu label Memtest86+\n\
  kernel /memtest/memtest86+\n\
LABEL ubuntu-16-04-amd64\n\
  MENU LABEL Ubuntu 16.04 amd64\n\
  KERNEL /ubuntu/16.04/16.04.2-server-amd64/install/netboot/ubuntu-installer/amd64/linux\n\
  APPEND /install/vmlinuz noapic auto=true interface=eth0 hostname=cluster domain=home url=tftp://192.168.56.2/preseed/16.04/preseed.cfg initrd=ubuntu/16.04/16.04.2-server-amd64/install/netboot/ubuntu-installer/amd64/initrd.gz debian-installer=en_US auto locale=en_US kbd-chooser/method=us keyboard-configuration/modelcode=SKIP keyboard-configuration/layout=USA keyboard-configuration/variant=USA console-setup/ask_detect=false --' > /var/lib/tftpboot/pxelinux.cfg/default \
  && ln -sf /usr/lib/PXELINUX/pxelinux.0 /var/lib/tftpboot/ \
  && ln -sf /usr/lib/syslinux/modules/bios/ldlinux.c32 /var/lib/tftpboot/

COPY preseed/ /var/lib/tftpboot/preseed/

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
