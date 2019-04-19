# (c) Copyright 2019 SUSE LLC
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# Load a "packages" manifest from a directory; cache these
# by default.

# Given such a dictionary, locate the latest version of a
# named package.
"""

A collection of filters to ensure that certain resources exist
in an OpenStack deployment.  This is helpful for letting users
know that images, networks, etc are missing prior to trying to
deploy vms against those images, networks.

"""

import os

from ansible.utils.display import Display
import openstack
from openstack.config import loader

display = Display()
CLOUD = os.getenv('OS_CLOUD', 'devstack')
# openstack.enable_logging(True, stream=sys.stdout)


def create_connection_from_config():
    #: Defines the OpenStack Config cloud key in your config file,
    #: typically in $HOME/.config/openstack/clouds.yaml. That configuration
    loader.OpenStackConfig()
    return openstack.connect(cloud=CLOUD)


def os_check_image(image_name):
    cloud = create_connection_from_config()
    found = False
    for img in cloud.image.images():
        if img.name == image_name:
            found = True
            break
    return found


def os_check_security_group(group_name):
    cloud = create_connection_from_config()
    found = False
    for sc in cloud.network.security_groups():
        if sc.name == group_name:
            found = True
            break

    return found


def os_check_network(net_name):
    cloud = create_connection_from_config()
    found = False
    for net in cloud.network.networks():
        if net.name == net_name:
            found = True
            break

    return found


def os_check_subnet(net_name):
    cloud = create_connection_from_config()
    found = False
    for net in cloud.network.subnets():
        if net.name == net_name:
            found = True
            break

    return found


class TestModule(object):
    def tests(self):
        return {'os_check_image': os_check_image,
                'os_check_network': os_check_network,
                'os_check_subnet': os_check_subnet,
                'os_check_security_group': os_check_security_group}
