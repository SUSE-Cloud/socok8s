#!/usr/bin/env python

import argparse
import datetime
import io
import json
import logging
import os.path
import re
import shutil
import time

import pygal
import requests

log = logging.getLogger(__name__)
log.setLevel(logging.DEBUG)

badges_tpl = """
<html>
  <head>
    <style>
      img { margin: .2em; }
    </style>
  </head>
  <body>
    BODY
  </body>
</html>
"""


def list_charts(ipaddr):
    url = "http://{}:19999/api/v1/charts".format(ipaddr)
    r = requests.get(url)
    j = r.json()
    chart_names = sorted(j["charts"].keys())
    return chart_names


def render_to_file(name, data, args):
    chart = pygal.Line(show_dots=False, height=args.height, width=args.width,
            explicit_size=True)
    chart.title = name
    # very slow:   chart.interpolate = "cubic"
    chart.x_labels = data["labels"][1:]
    for p, label in enumerate(data["labels"][1:]):
        vals = []
        for row in data["data"]:
            vals.append(row[p + 1])
        chart.add(label, vals)

    path = os.path.join(args.outdir, "charts", name + ".svg")
    log.debug("Generating %s", path)
    chart.render_to_file(path)

    # TODO add tests
    with io.open(path, "r", encoding="utf-8") as f:
        svg = f.read()
    start = svg.index('<script type')
    end = svg.index('</script>') + 9
    svg = svg[:start] + svg[end:]
    with open(path, 'w') as f:
        f.write(svg)


def generate_charts(ipaddr, chart_names, timedelta, args):
    url_tpl = 'http://{}:19999/api/v1/data?chart={}&after=-{}&points=400'
    for cn in chart_names:
        url = url_tpl.format(ipaddr, cn, timedelta)
        r = requests.get(url)
        if r.status_code == 200:
            j = r.json()
            render_to_file(cn, j, args)

def fetch_chart_data(ipaddr, chart_names, timedelta, args):
    url_tpl = 'http://{}:19999/api/v1/data?chart={}&after=-{}&format=datasource&options=nonzero'
    for cn in chart_names:
        url = url_tpl.format(ipaddr, cn, timedelta)
        r = requests.get(url)
        if r.status_code == 200:
            path = os.path.join(args.outdir, "data", cn + ".datasource")
            with open(path, 'wb') as f:
                f.write(r.content)

def fetch_badges(ipaddr, chart_names, timedelta, args):
    url_tpl = "http://{}:19999/api/v1/badge.svg?chart={}&after=-{}"
    body = "<table>"
    line = "<tr>"
    for cn in chart_names:
        url = url_tpl.format(ipaddr, cn, timedelta)
        r = requests.get(url)
        if r.status_code == 200:
            path = os.path.join(args.outdir, "badges", cn + ".svg")
            with open(path, 'wb') as f:
                f.write(r.content)
            line += """<td><img src="{}"></img></td>""".format(path)
            if len(line) > 60:
                body += line + "</td>"
                line = "<tr>"
    if len(line) > 5:
        body += line + "</tr>"
    body += "</table>"

    with open(os.path.join(args.outdir, 'badges/index.html'), 'w') as f:
        f.write(badges_tpl.replace('BODY', body))


def generate_charts_index(chart_names, timedelta, args):
    body = ""
    for cn in chart_names:
        body += """     <figure> <embed type="image/svg+xml" """ \
            """src="{}.svg" /></figure><br/>\n""".format(cn)

    with open(os.path.join(args.outdir, 'charts/charts.html'), 'w') as f:
        f.write(badges_tpl.replace('BODY', body))


def main():
    ap = argparse.ArgumentParser(description='Capture Netdata charts')
    ap.add_argument('target', choices=["admin", "master"], help="Target host")
    ap.add_argument('--env-json-path', default='./environment.json',
            help="environment.json full path")
    ap.add_argument('--timedelta', default='30minutes',
            help='Chart time: <numbers>[hours|minutes|seconds]')
    ap.add_argument('--height', type=int, default=300)
    ap.add_argument('--width', type=int, default=1200)
    ap.add_argument('--outdir', default='.', help='output directory')
    ap.add_argument('-l', '--logfile', help='logfile (Default: stdout)')
    args = ap.parse_args()
    args.outdir = os.path.abspath(args.outdir)
    if args.logfile:
        handler = logging.FileHandler(os.path.abspath(args.logfile))
    else:
        handler = logging.StreamHandler()
    log.addHandler(handler)

    m = re.match(r'(\d+)(hours|minutes|seconds)', args.timedelta)
    d = {m.group(2): int(m.group(1))}
    td = datetime.timedelta(**d).seconds

    with open(args.env_json_path) as f:
        env = json.load(f)
    target = [m for m in env["minions"] if m["role"] == args.target][0]
    ipaddr = target["addresses"]["privateIpv4"]

    os.makedirs(args.outdir, exist_ok=True)
    for d in ("badges", "data", "charts"):
        os.makedirs(os.path.join(args.outdir, d), exist_ok=True)

    chart_names = list_charts(ipaddr)
    generate_charts(ipaddr, chart_names, td, args)
    generate_charts_index(chart_names, td, args)
    fetch_badges(ipaddr, chart_names, td, args)
    fetch_chart_data(ipaddr, chart_names, td, args)




if __name__ == "__main__":
    main()
