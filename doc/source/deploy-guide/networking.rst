Networking Guide
================

Network guide for SUSE Openstack Containerized Control Plane.

Network function seperation, or isolating network traffic by function is common
in Openstack deployments. This guide will cover common options available in
this preview.

Kubernetes has built in network function seperation. We are layering Openstack
networking on top of kubernetes to create blended network configuration.

Networking will be setup in 2 places. Container As A Service Platform and
Openstack network configuration via airship yaml configuratoin.

Container As A Service Platform
===============================

SUSE Openstack CCP is designed to run on SUSE CAASPv3. Network configuration
of CAASP can be completed at installation time or modified after installation
by editing ifcfg-<interface> files in /etc/sysconfig/network on CAASP nodes..

Physical network interfaces can be bonded for high availability and vlans can
be used to seperate network traffic.

Additional details can be found in CAASP documentation for provisioning

NOTE:  Add network diagram

Openstack/SUSE CCP Configuration
================================

Network seperation in Airship is achieved by editing extravars file and
ses_config.yml. Differnet networks can be applied to different subsets of CAASP
nodes depending on groupings in SUSE CCP inventory file. `see SUSE CCP
inventory file for details`

Currently supported network seperation: 

* storage network: to be assigned to all SUSE CAASP nodes.
* managment (mgmt) network: needs to be assigned to all SUSE CAASP nodes.
* tunnel network: If used needs to be installed on all CAASP nodes.
* external network: needs to be installed on
  `airship-openstack-control-workers nodes`.

In order for these networks to be used on airship, we must specify either an ip
or an interface name depending on the function.

extravars
---------

sock8s_ext_vip: <ip address> defines the ip address that external api's are
exposed on (a network interface must exist with that ip addresses subnet
range).

sock8s_dcm_vip: <ip address> defines the ip address that mgmt api's are
exposed on (a network interface must exist with that ip addresses subnet
range).

tunnel_interface: <ethx>  (a network interface for vxlan traffic between
compute hosts)

ext_interface: <ethx>  (a network interface for access to public)

ses_config.yml
--------------

cluster_network: <ip/cidr> (does not need to be on caasp node).
mon_host: <ip> (ip must be in public cidr range).
public_network: <ip/cidr> (should be on all caasp nodes, minimally accessable
by all caasp nodes).
