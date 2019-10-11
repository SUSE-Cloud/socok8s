set -eu

mkdir -p ~/socok8s-workspace
export SOCOK8S_ENVNAME=jzerebecki-socok8s
export OS_CLOUD="engcloud"
# disabled because it is not used anymore: export SOCOK8S_DEVELOPER_MODE="True"
#export SOCOK8S_DEVELOPER_MODE="True"
export DEPLOYMENT_MECHANISM="openstack"
export ANSIBLE_STDOUT_CALLBACK="yaml"
export KEYNAME="socok8s"

export OS_AUTH_TYPE=token

export SOCOK8S_WORKSPACE_BASEDIR=~/socok8s-workspace
export USE_ARA='True'
export SOCOK8S_USE_VIRTUALENV=True

#TODO ntpd
#ntpdate 0.novell.pool.ntp.org
#in /etc/ntp.conf add
#server 0.novell.pool.ntp.org
#server 1.novell.pool.ntp.org
#server 2.novell.pool.ntp.org
#systemctl enable ntpd
#systemctl start ntpd


git submodule update --init --recursive

[[ -e ~/.ssh/id_rsa ]] || ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
ssh-add -l >/dev/null 2>&1 || eval `ssh-agent -s`
ssh-add

#TODO add skuba terraform to leap
zypper ar http://download.suse.de/ibs/SUSE:/SLE-15-SP1:/Update:/Products:/CASP40/standard/ skuba
zypper install -y ansible gcc jq python3-netaddr python3-virtualenv skuba terraform

if [[ ! -e ~/.ansible.cfg ]]; then
# TODO 
#python3 -m ara.setup.ansible | tee ~/.ansible.cfg
cat << EOF >> ~/.ansible.cfg
[ssh_connection]
pipelining = True
EOF
fi

if [[ ! -e ~/.config/openstack/clouds.yaml ]]; then
mkdir -p ~/.config/openstack
# TODO token
cat << EOF >> ~/.config/openstack/clouds.yaml
clouds:
  engcloud:
    region_name: CustomRegion
    auth:
      auth_url: https://engcloud.prv.suse.net:5000/v3
      token:
      project_name: cloud
      project_domain_name: default
    identity_api_version: 3
    cacert: /root/SUSE_Trust_Root.crt
EOF
fi

if [[ ! -e ~/SUSE_Trust_Root.crt ]]; then
cat << EOF >> ~/SUSE_Trust_Root.crt
-----BEGIN CERTIFICATE-----
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
-----END CERTIFICATE-----
EOF
fi

echo "to cleanup: openstack --os-cloud engcloud keypair delete socok8s"
openstack --os-cloud engcloud keypair show socok8s || openstack --os-cloud engcloud keypair create --public-key ~/.ssh/id_rsa.pub socok8s

# TODO this is only osh, also mention airship
echo "done. now: ./run.sh setup_everything"

set +eu
