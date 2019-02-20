### ssh-into

SSH into KVM / OpenStack / Bare metal hosts managed by CI

The tool captures the hosts ipaddrs and a copy of environment.json from the CI run log

Examples:

```sh
$ misc-tools/ssh-into <jenkins run URL> admin

# log into the second master
$ misc-tools/ssh-into <jenkins run URL> master -n1

# log into the third worker
$ misc-tools/ssh-into <jenkins run URL> worker -n2

```

#### Main options:

 -n  Host number, starting from 0
 -e  Load environment.json from disk
 -i  SSH identity / private key path

#### Help:

```
usage: ssh-into [-h] [-n N] [-e ENV_JSON_PATH] [-i SSHKEY] [-l LOGFILE]
                [--dumpjson]
                ci_run {admin,master,worker}


positional arguments:
  ci_run                CI run URL
  {admin,master,worker}
                        Target host

optional arguments:
  -h, --help            show this help message and exit
  -n N                  Host number (default: 0)
  -e ENV_JSON_PATH, --env-json-path ENV_JSON_PATH
                        environment.json full path (default: extract it from
                        Jenkins) (default: None)
  -i SSHKEY, --sshkey SSHKEY
                        SSH identity / private key path (default:
                        ~/.ssh/id_rsa)
  -l LOGFILE, --logfile LOGFILE
                        logfile (default: None)
  --dumpjson            Dump environment.json (default: False)
```

