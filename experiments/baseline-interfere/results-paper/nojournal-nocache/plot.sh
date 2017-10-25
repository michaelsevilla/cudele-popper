#!/bin/bash

set -ex
for i in `ls *.tar.gz`; do
  tar xzf $i
done

# prepare as a csv
for m in \
   "tmp/graphite/whisper/issdm-18/mds_mem/ino.wsp" \
   "tmp/graphite/whisper/issdm-18/mds_mem/ino+.wsp" \
   "tmp/graphite/whisper/issdm-18/mds_mem/ino-.wsp" \
   "tmp/graphite/whisper/issdm-18/mds/inodes.wsp" \
   "tmp/graphite/whisper/issdm-18/mds/inodes_bottom.wsp" \
   "tmp/graphite/whisper/issdm-18/mds/inodes_with_caps.wsp" \
   "tmp/graphite/whisper/issdm-18/mds/inodes_pin_tail.wsp" \
   "tmp/graphite/whisper/issdm-18/mds/inodes_pinned.wsp" \
   "tmp/graphite/whisper/issdm-18/mds/inodes_top.wsp" \
   "tmp/graphite/whisper/issdm-18/mds_server/handle_client_request_tput.wsp" \
   "tmp/graphite/whisper/issdm-18/cputotals/user.wsp" \
   "tmp/graphite/whisper/issdm-18/cputotals/sys.wsp" \
   "tmp/graphite/whisper/issdm-18/mds_server/req_create.wsp" \
   "tmp/graphite/whisper/issdm-18/mds_server/req_lookup.wsp" \
   ; do
  ../../../../../visualize.sh ${m}
  sed -i "s/:/,/g" `basename ${m}`.out
done

for osd in 0 1 14 24 27 29 34 40; do
  for m in "tmp/graphite/whisper/issdm-${osd}/disktotals/writekbs.wsp"; do
    ../../../../../visualize.sh ${m}
    sed -i "s/:/,/g" `basename ${m}`.out
    mv `basename ${m}`.out `basename ${m}`-issdm-${osd}.out
  done
done
