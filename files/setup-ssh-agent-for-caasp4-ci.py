#!/usr/bin/env python3

import subprocess
import sys
import os

if len(sys.argv) <= 1:
    print("We need an argument to continue")
    exit(1)

if len(sys.argv) > 2:
    print("More than one arg passed, ignoring them")

home = os.getenv("HOME")
subprocess.check_call("chmod 400 {}/.ssh/id_rsa".format(home), shell=True)
print("Starting ssh-agent ")
# use a dedicated agent to minimize stateful components
sock_fn = "/tmp/{}".format(sys.argv[1])
try:
    subprocess.check_call("rm " + sock_fn, shell=True)
    subprocess.check_call("pkill -f 'ssh-agent -a {}'".format(sock_fn), shell=True)
    print("Killed previous instance of ssh-agent")
except:
    pass
subprocess.check_call("ssh-agent -a {}".format(sock_fn), shell=True)
print("adding ssh key")
subprocess.check_call("ssh-add " + "{}/.ssh/id_rsa".format(home), env={"SSH_AUTH_SOCK": sock_fn}, shell=True)

print("Saving SSH_AUTH_SOCK vars to sock_{}".format(sys.argv[1]))
with open('sock_{}'.format(sys.argv[1]), 'w') as file:
    file.write("export SSH_AUTH_SOCK={}".format(sock_fn))