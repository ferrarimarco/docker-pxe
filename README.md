# Dockerized PXE
[![Docker Pulls](https://img.shields.io/docker/pulls/ferrarimarco/pxe.svg)](https://hub.docker.com/r/ferrarimarco/pxe/)
[![Docker Automated build](https://img.shields.io/docker/automated/ferrarimarco/pxe.svg)](https://hub.docker.com/r/ferrarimarco/pxe/)

A Docker image serving as a standalone [PXE](https://en.wikipedia.org/wiki/Preboot_Execution_Environment) (running Dnsmasq). This server can be placed in an existing network infrastructure with an already configured DHCP server or in a network without any DHCP server.

This PXE currently serves:
- [MemTest86+](http://www.memtest86.com/)

## Dependencies
These are the dependencies required to build and run the box:
- Docker 1.12+

## How to run
The `ENTRYPOINT` of this image is set to run `dnsmasq` in `no-daemon` mode. Add your desired `dhcp-range`s as command line options (see [dnsmasq documentation](http://www.thekelleys.org.uk/dnsmasq/docs/dnsmasq-man.html) for details). Note that you can specify more than one range by adding multiple `dhcp-range` options.

The easiest way to use instances of this image to provide a PXE in an existing network is to run a container based on it with the `--net=host` option.

To sum up: `docker run -it --rm --net=host ferrarimarco/pxe`

If you want to inspect the container just run it overwriting the entrypoint: `--entrypoint=/bin/sh`

### Integrated DHCP server
If you want to enable the integrated DHCP server for a given IP address range add a `dhcp-range` option: `dhcp-range=x.x.x.x,y.y.y.y,z.z.z.z` where `x.x.x.x` is the start of the range, `y.y.y.y` is the end and `z.z.z.z` is the subnet mask.

### Standalone DHCP server
If you want to use an existing DHCP server and let `dnsmasq` handle only the PXE, add a `dhcp-range` option: `dhcp-range=x.x.x.x,proxy` where `x.x.x.x` is the IP address of the server running dnsmasq.

## How to modify the configuration

All the configuration files can be modified at will. Just look at the Dockerfile to see where they are (mainly in `/etc` and `/var/lib/tftpboot`) and overwrite them with your own (mounting volumes from the Docker host or rebuilding the image).

### Additional PXE Boot Menu Entries

If you just want to add additional menu entries to the boot menu, just overwrite the contents of `/var/lib/tftpboot/pxelinux.cfg/additional_menu_entries` file.
The syntax for this file is described in the [syslinux documentation](http://www.syslinux.org/wiki/index.php?title=Config).

#### Example: 2nd Memtest86+ plus Ubuntu 16.04 Boot Options
Here is an `additional_menu_entries` file to include (along with the default Memtest86+) two additional boot options: a customized Memtest86+ and Ubuntu 16.04.

```
LABEL memtest86-2
  MENU LABEL Memtest86+ 2nd entry
  KERNEL /memtest/memtest86+
LABEL ubuntu-16-04-amd64
  MENU LABEL Ubuntu 16.04 amd64
  KERNEL /ubuntu/16.04/16.04.2-server-amd64/install/netboot/ubuntu-installer/amd64/linux
  APPEND /install/vmlinuz auto=true interface=eth0 hostname=cluster domain=home url=tftp://<pxe-container-ip>/preseed/16.04/preseed.cfg initrd=ubuntu/16.04/16.04.2-server-amd64/install/netboot/ubuntu-installer/amd64/initrd.gz debian-installer=en_US locale=en_US kbd-chooser/method=us keyboard-configuration/modelcode=SKIP keyboard-configuration/layout=USA keyboard-configuration/variant=USA console-setup/ask_detect=false --
```

## Testing and validating the setup
### Dependencies

1. Virtualbox 5.1.16+
1. Vagrant 1.9.3+

### How to run

After running the container with a suitable DHCP configuration (see above for instructions) and the `--net=host` option, you can run `vagrant up` from the root of the project. A Virtualbox VM (with a NATed network adapter) will boot from the given PXE.

Note that you should check the IP address ranged configured by the Virtualbox DHCP server (if enabled) and configure your `dhcp-range` and `/var/lib/tftpboot/pxelinux.cfg/default` accordingly.

#### Example

Virtualbox runs a DHCP server by default in each virtual network. If you want to test the PXE feature you have to run a container based on this image with DNSMasq as a DHCP proxy (see [Standalone Mode](#standalone-dhcp-server)) and with the host network stack (see the `--net=host` option) so you know in advance the IP address of the container running DNSMasq: it's the same as the Docker host!

If Virtualbox DHCP server assigns addresses in the `192.168.56.0/24` subnet (check the virtual network configuration of the Host-only network assigned to a VM to know this), then the `dhcp-range` could be: `dhcp-range=192.168.56.2,proxy`, where `192.168.56.2` is the address assigned to the Docker host running the container based on this image in "host network" mode. Remember to also update any IP address in `/var/lib/tftpboot/pxelinux.cfg/default` you may have configured, if you serve any content from the TFTP server (like a `preseed.cfg` for example) to point to the IP address of the container running this PXE. **For this reason it could be useful to manually assign (or reserve) IP addresses (or better, hostnames!) for containers running this PXE.**

## Contributions
If you have suggestions, please create a new GitHub issue or a pull request.
