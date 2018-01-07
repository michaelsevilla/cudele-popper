#! /usr/bin/python
import os
import sys
import pickle
import struct
import socket
import json
import argparse
import time

# recurse down the json object and convert to paths
def json_to_path(metrics, date, path, data):
  if type(data) == dict:
    for x in data:
      json_to_path(metrics, date, path + "." + x, data[x])
  else:
    metrics[path] = (date, data)
  return metrics

# manage as dictionary so we can search it (for throughputs)
#   [(name, (timestamp, value)), ...]
def json_to_dict(date, data):
  metrics = json_to_path({}, date, socket.gethostname(), data)
  return metrics

# convert a metric to throughput
def throughput(name, pmetric, metric, interval):
  p = pmetrics[name]
  m = metrics[name]
  t = float(m[0]) - float(p[0])
  d = float(m[1]) - float(p[1])
  tput = (m[0], d/interval)
  print "throughput: tput=" + str(tput) + " m=" + str(m) + " p=" + str(p) + " time=" + str(t) + " diff=" + str(d)
  return tput
  
# main
parser = argparse.ArgumentParser(description='Parse Ceph perf counter dump and send to graphite')
parser.add_argument('ip', metavar='ip', type=str, help='where the graphite collector daemon (carbon) lives')
parser.add_argument('--port', metavar='p', type=int, default=2004, help='port of the graphite collector daemon (carbon)')
parser.add_argument('--interval', metavar='i', type=int, default=1, help='port of the graphite collector daemon (carbon)')
parser.add_argument('--jsonfile', metavar='f', type=str, default="/tmp/ceph_perf_dump.json", help='where the json dump is')
parser.add_argument('--throughput', metavar='t', type=bool, default=True, help='whether to collect throughput')
args = parser.parse_args()
print "args:", args

# connect to graphite
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect((args.ip, args.port))

pmetrics = {}
pdate = -1
while 1:
    time.sleep(args.interval)

    # get the current time
    f = os.popen('date +%s')
    date = f.read().strip('\n')

    # read the perf dump
    os.popen("ceph --admin-daemon /var/run/ceph/ceph-mds* perf dump > " + args.jsonfile)
    try:
      with open(args.jsonfile) as f:
        metrics = json_to_dict(date, json.load(f))
    except IOError:
      print "WARNING: couldn't find JSON dump, did you dump the Ceph JSON (" + args.jsonfile + ")?"
      continue
    except ValueError:
      print "ERROR: couldn't read the JSON dump, malformed"
      continue

    # calculate throughput
    if (args.throughput and len(pmetrics) > 0):
      key = socket.gethostname() + ".mds_server.handle_client_request"
      metrics[key + "_tput"] = throughput(key, pmetrics, metrics, float(args.interval))

    # save off the previous metrics
    pmetrics = metrics;
    pdate = date;
 
    # send list of tuples off to graphite 
    m = [(k, v) for k, v in metrics.iteritems()]
    payload = pickle.dumps(m, protocol=2)
    header = struct.pack("!L", len(payload))
    s.send(header + payload)
    print "... sent to", args.ip, "at port", args.port
