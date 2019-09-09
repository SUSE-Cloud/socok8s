How to use this?

If you want to use this scripts for developer usage you should:
- define env var DEPLOYMENT_MECHANISM (libvirt or openstack)
- define env var SOCOK8S_WORKSPACE (for example /home/jean-philippe/jevrard3-workspace/ )
- define env var SOCOK8S_ENVNAME jevrard3
- have access to registry.suse.de
- have podman installed
- have SSH_AUTH_SOCK env var defined, and your keys added to your agent
  (ssh-add -L should return results)

KVM specific requirements:

- LIBVIRT_DEFAULT_URI env var defined like qemu+tcp://192.168.102.196:16509/system
- LIBVIRT tcp access. (https://wiki.archlinux.org/index.php/Libvirt#Unencrypt_TCP/IP_sockets)
- virsh pool-list should have a default pool defined, active*

OpenStack specific requirements

- Have a clouds.yaml file in the standard locations (~/.config/openstack or /etc/openstack)
- Have the OS_CLOUD env var defined.

Optional:

- define IMAGE_USERNAME if the image you're using doesn't use the username "sles".


To define the libvirt pool:

- `virsh pool-define-as default dir - - - - /images`
- `virsh pool-build default`
- `virsh pool-start default`
- `virsh pool-autostart default`
