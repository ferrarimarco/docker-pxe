FROM alpine:3.10.1

LABEL maintainer "ferrari.marco@gmail.com"

# Install the necessary packages
RUN apk add --update \
  dnsmasq \
  wget \
  && rm -rf /var/cache/apk/*

ENV SYSLINUX_VERSION 6.03
ENV TEMP_SYSLINUX_PATH /tmp/syslinux-"$SYSLINUX_VERSION"
WORKDIR /tmp
RUN \
  mkdir -p "$TEMP_SYSLINUX_PATH" \
  && wget -q https://www.kernel.org/pub/linux/utils/boot/syslinux/syslinux-"$SYSLINUX_VERSION".tar.gz \
  && tar -xzf syslinux-"$SYSLINUX_VERSION".tar.gz \
  && mkdir -p /var/lib/tftpboot \
  && cp "$TEMP_SYSLINUX_PATH"/bios/core/pxelinux.0 /var/lib/tftpboot/ \
  && cp "$TEMP_SYSLINUX_PATH"/bios/com32/libutil/libutil.c32 /var/lib/tftpboot/ \
  && cp "$TEMP_SYSLINUX_PATH"/bios/com32/elflink/ldlinux/ldlinux.c32 /var/lib/tftpboot/ \
  && cp "$TEMP_SYSLINUX_PATH"/bios/com32/menu/menu.c32 /var/lib/tftpboot/ \
  && rm -rf "$TEMP_SYSLINUX_PATH" \
  && rm /tmp/syslinux-"$SYSLINUX_VERSION".tar.gz

# Download and extract MemTest86+
ENV MEMTEST_VERSION 5.01
RUN wget -q http://www.memtest.org/download/"$MEMTEST_VERSION"/memtest86+-"$MEMTEST_VERSION".bin.gz \
  && gzip -d memtest86+-"$MEMTEST_VERSION".bin.gz \
  && mkdir -p /var/lib/tftpboot/memtest \
  && mv memtest86+-$MEMTEST_VERSION.bin /var/lib/tftpboot/memtest/memtest86+

# Configure PXE and TFTP
COPY tftpboot/ /var/lib/tftpboot

# Configure DNSMASQ
COPY etc/ /etc

# Start dnsmasq. It picks up default configuration from /etc/dnsmasq.conf and
# /etc/default/dnsmasq plus any command line switch
ENTRYPOINT ["dnsmasq", "--no-daemon"]
CMD ["--dhcp-range=192.168.56.2,proxy"]
