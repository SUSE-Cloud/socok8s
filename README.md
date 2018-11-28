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


# Deployment using KVM

This is not currently supported, but is a planned future addition.

# Deployment using manually-installed SES and CAASP

While a fully automated baremetal or VM based installation is not
currently supported, selected parts of the automated install process
can be used to configure existing SES and CAASP nodes. Here is an
overview of how to do this. Note that these instructions are a work in
progress and do not currently provide a comprehensive overview of
installing SES and CAASP themselves.

## Manually installing nodes

Install SLES12SP3 with the SES5 extension from the SLES12SP3
ISO. Please ensure that your SES system has a second disk device
available.

Install a CAASP admin, master, and two worker nodes manually from the
CAASP ISO, setting the hostname on each node at install time. Visit
the admin web interface and configure it, being sure to install
Tiller.

You will also want a system that acts as a deployer, which should have
SSH access via keys to the CAASP and SES nodes. Note that the
playbooks currently expect to use the root user on the remote systems
and you may have better luck running the playbooks as the root user on
your deployer as well.

## Manually running Stage 2 to configure SES

On your deployer, check out this repository. Be sure to import the git
submodules as above. In the top level of the repository, create a file
named .ses_ip containing the IP address of your SES node. Also create
a file named inventory-ses.ini with the following contents:

ses ansible_ssh_host=<SES IP> ansible_user=root ansible_ssh_user=root

On the SES node, you will need to either configure SuSEfirewall2 to
allow access to the SSH port, or disable SuSEfirewall2 entirely. Next,
add a /root/.ssh/authorized_keys file containing the id_rsa.pub from
your deployer. Finally, note that the SES node must have a FQDN in
/etc/hosts, such as mycaasp.local for all steps to succeed.

Now you are ready to run the Stage 2 playbooks. From the top level of
this repository, run ./2_deploy_ses_aio/run.sh.

## Manually running Stage 7 to run OpenStack Helm

Prior to running Stage 7, you will need to perform additional
configuration on the deployer.

On the deployer:

- Create an inventory-osh.ini file in the top level of this
  repository. To do this, copy the file from
  examples/config/inventory-osh.ini and edit it to reflect your
  environment.

- Enable and start sshd on your deployer and the location you are
  running the playbooks. [NOTE: this step can be removed or adapted
  subject to merge of PR #29]

- Add suse_osh_deploy_vip_with_cidr to
  ~/suse-osh-deploy/user_variables.yml. This should be an IP available
  on the network you're using which can be used as a VIP.

- Download the kubeconfig from Velum on the CAASP admin node and copy
  it to ~/suse-osh-deploy/kubeconfig and ~/.kube/config

- pip install --upgrade pip to avoid segfaults when installing
  openstack clients.

- pip install jmespath netaddr

On each CAASP node:

- add id_rsa.pub to root's authorized_keys file.

Now you are ready to run Stage 7, as follows:

ansible-playbook -vvv -e @~/suse-osh-deploy/user_variables.yml
./7_deploy_osh/play.yml -i inventory-osh.ini
