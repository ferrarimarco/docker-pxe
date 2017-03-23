# Vagrant PXE

A Vagrant box serving as a PXE server (running Dnsmasq).

## Dependencies
These are the dependencies required to build and run the box:
- Vagrant 1.9.3+
- Virtualbox 5.1.18+

## How to Run
To build the box:

1. Install the dependencies
1. Clone this repository
1. Run `vagrant up` from inside the cloned repository directory

## How to validate the setup
A possible test strategy is to manually create (via the CLI of the GUI) an empty
Virtualbox VM configured in the following way:
1. Only one network interface connected to the default "intnet" internal network
1. Boot from network as the first boot choice

Note that this manually created VM should not have other network interfaces
because it could interfere with the DHCP server provided by Dnsmasq.
This machine cannot not be configured with Vagrant (as of version 1.9.3) because
it would have two network interfaces as Vagrant needs a NATed eth0 interface to
talk with each machine, so it cannot have only one "internal network" interface.

## Contributions
If you have suggestions, please create a new GitHub issue or a pull request.
