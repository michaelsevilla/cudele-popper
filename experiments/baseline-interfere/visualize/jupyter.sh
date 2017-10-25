#!/bin/bash

if [ $# -lt 1 ]; then
  echo "USAGE <re-parse>"
  echo "- where re-parse is 0 or 1"
  exit 1
fi

set -e -x
function uncompress() {
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
}

if [ "$1" -eq 1 ]; then
  cd ../results-paper/nojournal-cache/
  uncompress
  cd -
fi
mkdir graphs || true
docker run --rm -v  `dirname $PWD | xargs dirname`:/home/jovyan/work -p 81:8888 jupyter/scipy-notebook:c411f52fcc93

