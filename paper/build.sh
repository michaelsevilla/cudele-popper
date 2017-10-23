#!/bin/bash

rm -r _minted-paper paper.aux paper.bbl paper.blg paper.log paper.out paper.synctex.gz build.log >> /dev/null 2>&1
set -x
cp biblio/references.bib paper.bib

# Build the paper
docker run --rm \
  --name latex \
  --entrypoint=/bin/bash \
  -v `pwd`/:/mnt \
  michaelsevilla/texlive:latest -c \
    "cd /mnt ; \
     pdflatex -synctex=1 -interaction=nonstopmode -shell-escape paper; \
     bibtex paper; \
     pdflatex -synctex=1 -interaction=nonstopmode -shell-escape paper; \
     pdflatex -synctex=1 -interaction=nonstopmode -shell-escape paper;" &> build.log

ERR=$?
if [ $ERR != "0" ] ; then
  echo "ERROR: $ERR"
  cat build.log
fi

set +e
rm -r _minted-paper paper.aux paper.bbl paper.blg paper.log paper.out paper.synctex.gz build.log >> /dev/null 2>&1

echo "SUCCESS"

