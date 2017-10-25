#!/bin/bash

set -ex
for i in `ls *.tar.gz`; do
  tar xzf $i
done

GRAPHITE="docker run -v `pwd`/tmp:/tmp --entrypoint=/bin/bash -it michaelsevilla/graphite -c"

# prepare as a csv
for m in \
   "tmp/graphite/whisper/issdm-18/mds_server/handle_client_request_tput.wsp" \
   "tmp/graphite/whisper/issdm-18/mds_server/req_lookup.wsp" \
   ; do
  $GRAPHITE "whisper-dump.py $m > tmp/`basename $m.out`"
  $GRAPHITE "sed -i 's/:/,/g' tmp/`basename ${m}.out`"
done
