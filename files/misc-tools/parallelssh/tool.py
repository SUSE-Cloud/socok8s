#!/usr/bin/env python

"""
    SSH into KVM / OpenStack / Bare metal hosts managed by CI in parallel
"""

from argparse import ArgumentParser, ArgumentDefaultsHelpFormatter, REMAINDER
import json
import logging
import os
import subprocess
import sys
import urllib.request

log = logging.getLogger(__name__)
log.setLevel(logging.DEBUG)

PSSH_PATH = "/usr/bin/pssh"
PSSH_CMD_TPL = PSSH_PATH + """ -iP -H "{hosts}" -x "-oStrictHostKeyChecking=no -i{key} -tt" -t {timeout} -l {sshuser} -- {cmd}"""


def parse_args():
    example = "Example: parallel-ssh -e environment.json -i id_shared all -- journalctl -f"
    ap = ArgumentParser(description=__doc__,
        formatter_class=ArgumentDefaultsHelpFormatter,
        epilog=example
    )
    ap.add_argument('target_roles', choices=["admin", "master", "worker", "all"],
            help="Target hosts role")
    ap.add_argument('-e', '--env-json-path', help="environment.json full path")
    ap.add_argument('--ci-run', help="CI run URL - used to extract environment.json")
    ap.add_argument('-i', '--sshkey', help="SSH identity / private key path",
                    default="~/.ssh/id_rsa")
    ap.add_argument('-l', '--logfile', help='logfile')
    ap.add_argument('-d', '--daemonize',  action="store_true", help="Run in background")
    ap.add_argument('--timeout', type=int, help='timeout', default=0)
    ap.add_argument('--dumpjson', help='Dump environment.json', action="store_true")
    ap.add_argument('cmd', nargs=REMAINDER,
            help="command to run. Use -- to protect its arguments")
    ap.add_argument('-k', '--stop', action="store_true",
            help="stop running pssh. Requires the same arguments used when starting the pssh instance")
    args = ap.parse_args()
    return args


def fetch_ci_run_log(url):
    # Fetch CI run log
    if not url.endswith("consoleText"):
        url = url.rstrip("/") + "/consoleText"

    with urllib.request.urlopen(url) as r:
        text = r.read().decode()

    if len(text) < 3000:
        log.error("The worker has not been assigned yet or the build failed early")
        sys.exit(1)

    return text


def fetch_environment_json(args, text):
    # Load or extract environment.json
    if args.env_json_path:
        with open(args.env_json_path) as f:
            env = json.load(f)
    else:
        env = None
        start = 0
        while True:
            start = text.find("\n+ cat /", start)
            if start == -1: break
            start = text.find("/environment.json\n", start)
            if start == -1: break
            start = text.find("{", start)
            end = text.find("\n}", start)
            j = text[start:end+2]
            start = end
            env = json.loads(j)

    if not env:
        log.error("environment.json has not been created yet or the build failed earlier")
        sys.exit(1)

    return env


def extract_target_ipaddrs(args, env):
    # Extract target host ipaddrs
    role = args.target_roles.rstrip('s')
    target_ipaddrs = [
        b["addresses"]["privateIpv4"] for b in env["minions"]
        if role in ("all", b["role"])
    ]
    if not target_ipaddrs:
        log.error("hosts not found in environment.json")
        sys.exit(1)
    return target_ipaddrs


def run_ssh_interactive(sshuser, sshkey, target_ipaddrs, cmd, timeout, stop):
    hosts = ' '.join(target_ipaddrs)
    cmd = ' '.join(cmd)
    cmd = PSSH_CMD_TPL.format(hosts=hosts, key=sshkey, sshuser=sshuser,
        timeout=timeout, cmd=cmd)

    if stop:
        # pkill running instance
        cmd = cmd.replace('"', '')
        cmd = cmd.split('pssh')[1]
        cmd = "pkill -f '.*pssh{}'".format(cmd)
        try:
            retcode = subprocess.call(cmd, shell=True)
            if retcode:
                log.info("Executed: %s", cmd)
                log.info("There is no running process!")
            else:
                log.info("Process stopped")
            sys.exit()

        except OSError as e:
            log.info("Execution failed: %s", e)
        sys.exit(1)

    log.debug("Running %s", cmd)
    try:
        retcode = subprocess.call(cmd, shell=True)
        if retcode == -15:
            log.info("parallel-ssh exiting as requested")
        elif retcode < 0:
            log.info("Child was terminated by signal %s", -retcode)
        else:
            log.info("Child returned %s", retcode)
    except OSError as e:
        log.info("Execution failed: %s", e)


def daemonize():
    if os.fork() > 0:
        sys.exit()
    os.setsid()
    os.umask(0)
    pid = os.fork()
    if pid > 0:
        log.debug("Running in background with PID %d", pid)
        sys.exit()


def main():
    args = parse_args()

    if args.logfile:
        handler = logging.FileHandler(os.path.abspath(args.logfile))
    else:
        handler = logging.StreamHandler()
    log.addHandler(handler)

    if args.ci_run:
        text = fetch_ci_run_log(args.ci_run)
        env = fetch_environment_json(args, text)
    elif args.env_json_path:
        with open(args.env_json_path) as f:
            env = json.load(f)
    else:
        print("Either -e/--env-json-path or --ci-run is required")
        sys.exit(1)

    if args.daemonize and not args.stop:
        daemonize()

    # Dump environment.json
    if args.dumpjson:
        log.info(json.dumps(env, indent=2, sort_keys=True))

    sshuser = env['sshUser']
    if not args.sshkey:
        args.sshkey = "~/.ssh/" + env['sshKey']

    target_ipaddrs = extract_target_ipaddrs(args, env)
    run_ssh_interactive(sshuser, args.sshkey, target_ipaddrs, args.cmd,
            args.timeout, args.stop)


if __name__ == '__main__':
    sys.exit(main())
