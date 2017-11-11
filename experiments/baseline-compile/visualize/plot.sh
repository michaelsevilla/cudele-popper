#!/bin/bash

set -ex
cd ../results
#for i in `ls *.tar.gz`; do
#  tar xzf $i
#done
#
## prepare as a csv
#for m in \
#   "tmp/graphite/whisper/issdm-12/mds_server/req_create.wsp" \
#   "tmp/graphite/whisper/issdm-12/mds_server/req_readdir.wsp" \
#   "tmp/graphite/whisper/issdm-12/mds_server/req_lookup.wsp" \
#   ; do
for m in \
    "tmp/graphite/whisper/issdm-12/mds_server/req_unlink.wsp" \
    "tmp/graphite/whisper/issdm-12/mds_server/req_rmdir.wsp" \
    ; do
  docker run \
    -v `pwd`/tmp:/tmp \
    --entrypoint=whisper-dump.py \
    michaelsevilla/graphite \
    $m > `basename $m`.out
  sed -i "s/:/,/g" `basename ${m}`.out
done
cd -
