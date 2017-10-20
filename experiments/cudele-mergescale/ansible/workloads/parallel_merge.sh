#!/bin/bash

if [ $# -lt 2 ]; then
  echo "USAGE: $0 <mds name> <number of journals>"
  exit 1
fi

set -e
for i in `seq 0 $2`; do
  ceph daemon mds.$1 merge /etc/ceph/events-${i}.bin &
done

echo "waiting..."
wait
