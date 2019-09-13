# OPTIONAL

# absolute path to clouds.yaml
# if not provided, the script searches the openstackclient paths
#export CLUSTERCTL_CLOUDS_YAML=

# absolute path to clusterctl configuration files
# if not provided, the script creates it's own output directory
#export CLUSTERCTL_CONFDIR=


# REQUIRED

# cloud definition in clouds.yaml
export CLUSTERCTL_OS_CLOUD=engcloud

# cluster name (unique within bootstrap cluster)
export CLUSTERCTL_CLUSTER_NAME=cluster1

# instance prefix (unique within OpenStack env)
export CLUSTERCTL_INSTANCE_PREFIX=username-clusterapi

# existing keypair within OpenStack env
export CLUSTERCTL_KEYPAIR=username_keypair

# pre-allocated floating IP for master node (grab one from either of the example cmds below)
#   - openstack floating ip list --network floating --status DOWN
#   - openstack floating ip create floating
export CLUSTERCTL_MASTER_FLOATING_IP=10.24.4.21

export CLUSTERCTL_WORKER_COUNT=3

# private network ID(s)
export CLUSTERCTL_NETWORK_IDS=8b038da2-77a3-4fd8-a4cc-886441ef24bc

# security group IDs (ping, ssh, kubernetes, etc)
export CLUSTERCTL_SECGROUP_IDS=818680e2-d37f-493e-9a82-7694b7088ead,1241d0d6-f656-4bbe-bae6-13a8ef2f7614,d423d155-8fe5-495d-af1f-5fb023260f3c

# clusterctl supported OS (i.e. from ls cmd/clusterctl/examples/openstack/provider-component/user-data/<supported_os>/*-user-data.sh)
export CLUSTERCTL_USERDATA_OS=ubuntu

export CLUSTERCTL_IMAGE=ubuntu-16.04-server-cloudimg-amd64-disk1.img
export CLUSTERCTL_FLAVOR=m1.medium
