#!/bin/bash

set -ex
cd ../$1
for i in `ls *.tar.gz`; do
  tar xzf $i
done

# prepare as a csv
for m in \
   "tmp/graphite/whisper/node-4/nettotals/kbout/eth0.wsp" \
   "tmp/graphite/whisper/node-4/nettotals/kbout/eth1.wsp" \
   "tmp/graphite/whisper/node-4/nettotals/kbout/eth2.wsp" \
   "tmp/graphite/whisper/node-4/nettotals/kbout/eth3.wsp" \
   "tmp/graphite/whisper/node-4/nettotals/kbin/eth0.wsp" \
   "tmp/graphite/whisper/node-4/nettotals/kbin/eth1.wsp" \
   "tmp/graphite/whisper/node-4/nettotals/kbin/eth2.wsp" \
   "tmp/graphite/whisper/node-4/nettotals/kbin/eth3.wsp" \
  ; do
  FNAME=`dirname $m | xargs basename`-`basename $m`.out

  # dump trace
  docker run \
    -v `pwd`/tmp:/tmp \
    --entrypoint=whisper-dump.py \
    michaelsevilla/graphite \
    $m > $FNAME

  # clean trace to prepare for pandas
  docker run \
    -v `pwd`:/root \
    --entrypoint=/bin/bash \
    michaelsevilla/graphite \
    -c "sed -i \"s/:/,/g\" /root/$FNAME"

done

cd -
