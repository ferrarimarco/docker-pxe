# Dockerized PXE
A Docker image serving as a standalone [PXE](https://en.wikipedia.org/wiki/Preboot_Execution_Environment)
(running Dnsmasq). This server can be placed in an existing network
infrastructure (with an already configured DHCP server) or in a network without
any DHCP server.

This PXE currently serves:
- [MemTest86+](http://www.memtest86.com/)

## Dependencies
These are the dependencies required to build and run the box:
- Docker 1.12+

## How to run
The `ENTRYPOINT` of this image is set to run `dnsmasq` in `no-daemon` mode.
Add your desired `dhcp-range`s as command line options (see
[dnsmasq documentation](http://www.thekelleys.org.uk/dnsmasq/docs/dnsmasq-man.html)
for details). Note that you can specify more than one range by adding multiple
`dhcp-range` options.

The easiest way to use instances of this image to provide a PXE in an existing
network is to run a container based on it with the `--net=host` option.

### Integrated DHCP server
If you want to enable the integrated DHCP server for a given IP address range
add a `dhcp-range` option: `dhcp-range=x.x.x.x,y.y.y.y,z.z.z.z` where `x.x.x.x`
is the start of the range, `y.y.y.y` is the end and `z.z.z.z` is the subnet
mask.

### Standalone DHCP server
If you want to use an existing DHCP server and let dnsmasq handle only the PXE,
add a `dhcp-range` option: `dhcp-range=x.x.x.x,proxy` where `x.x.x.x` is the IP
address of the server running dnsmasq.

## How to validate the setup
A possible test strategy is to manually create (via CLI or GUI) an empty
Virtualbox VM configured in the following way:
1. One `Host-only`network interface
1. Boot from network as the first boot choice

## Contributions
If you have suggestions, please create a new GitHub issue or a pull request.
