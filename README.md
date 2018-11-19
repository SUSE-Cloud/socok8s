# fictional-octo-doodle
fictional-octo-doodle

This project automates the deployment of OpenStack Helm on CAASP and
SES via a series of shell scripts and Ansible playbooks.

# Deployment on SUSE engcloud

On the system you plan to deploy OSH from, you'll need to install some
software and create local configuration. Install Ansible 2.7 or
later. Install the OpenStack and Heat CLI. Install the jq utility.

In your clone of this repository, run "git submodule update --init
--recursive" to fetch the git submodules required for the CAASP
deployment.

Set up access to engcloud. You can access the engcloud web UI at
https://engcloud.prv.suse.net/. For more information, see
https://wiki.microfocus.net/index.php/SUSE/ECP. You'll need to create
the ~/.config/openstack/clouds.yaml. The contents of the file should
look like the following, plus the substitution of your username and
password. If you don't have the SUSE root certificate installed, check
http://ca.suse.de/.

clouds:
  engcloud-me:
    region_name: CustomRegion
    auth:
      auth_url: https://engcloud.prv.suse.net:5000/v3
      username: foctodoodle # your username here
      password: my-super-secret-password # your password here
      project_name: cloud
      project_domain_name: default
      user_domain_name: ldap_users
    identity_api_version: 3
    cacert: /usr/share/pki/trust/anchors/SUSE_Trust_Root.crt.pem

You'll also need to pre-create some configuration in engcloud. It's
convention here to use your username as part of the name of objects you create.

Using the engcloud web interface or OpenStack CLI (i.e. "openstack
keypair create..."), create a keypair
for accessing the instances created. Remember the name of this
keypair.

Using the engcloud web interface, create a network with a subnet. Take
note of the network name you used. Then
create a router with the 'floating' external network.  Then open the
router and add an interface to the network you created.

Define the following environment variables prior to running the
socok8s scripts:

# assuming you followed the example
export OS_CLOUD=engcloud-me
# the name of the keypair you created
export KEYNAME=foctodoodle-key
# your username plus whatever else you'd like, will be used for naming
# objects you create in engcloud
export PREFIX=foctodoodle
# the name of the subnet you created
export INTERNAL_SUBNET=foctodoodle-subnet

Prior to executing scripts, be aware that you may need to do some
cleanup prior to retrying scripts or playbooks should they fail. In
some steps a delete.sh script is provided to clean up any created
resources. Reconfirming that you've done all the previous steps to set
up now will save you some time later.

To begin a deployment from scratch, go to the root of your socok8s
clone and run "./run.sh". This will run each of the seven top-level
sections of the script in order.

## Reference archiecture and inventories

By default, it is expected these playbooks and scripts would run
on a CI/developer machine.

In order to not pollute the developer/CI machine (called further
'localhost'), all the data relevant for a deployment (like any
eventual override) will be stored in user-space, unpriviledged
access. Any hardware and software distribution can be used,
as long as 'localhost' is able to run git, and ansible
(see requirements). This also helps the story of running behind
a corporate firewall: the 'developer' can be (connecting to)
a bastion host, while the real actions happen behind the firewall.

This SoCok8s deployment mechanism requires therefore another
entity, another machine, to orchestrate kubernetes commands.
This machine is named the `deployer` node.
The `deployer` node will be in charge of running the OSH code,
and manage the kubernetes configuration.

The `deployer` node is expected to run SLE.

The deployer node can be the same as the `localhost`
(developer/CI machine), but it is not a requirement.

The deployer node (currently) needs access to the SES machines
through SSH to fetch the keys. In the future, this SSH connection
might be skipped if the `localhost` have knowledge of these keys.

### Example inventories and conventions

In order for a deployer to bring its own inventory, we have
defined a set of convention about inventory groupnames.

* All nodes belonging to the SES deployment should be listed
  under the `ses_nodes` group. First node in this group must
  be a monitor node with the appropriate ceph keyrings in
  `/etc/ceph/`.

* The inventory for SES nodes is stored in `inventory-ses.ini`
  by default.

* The CI/developer machine is always named `localhost`.

* The `deployer` node is listed in a group `osh-deployer`.
  In order to not extend the length of the deployment,
  the `osh-deployer` group should contain only one node.
  We might support multiple `osh-deployer` nodes for
  muliple k8s deployments later.

* The inventory for the `deployer` node is stored in
  `inventory-osh.ini` by default.

* Example inventories and user variables can be found
  in the `examples/` directory.

# Deployment using KVM

This is not currently supported, but is a planned future addition.
