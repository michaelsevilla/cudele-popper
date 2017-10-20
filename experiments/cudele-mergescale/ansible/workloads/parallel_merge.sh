#!/bin/bash

if [ $# -lt 3 ]; then
  echo "USAGE: $0 <mds name> <number of journals> <interval>"
  exit 1
fi

set -e
for i in `seq 0 $2`; do
  ceph daemon mds.$1 merge /etc/ceph/events-${i}.bin
  sleep $3
done

echo "waiting..."
wait
