#!/bin/bash

rm -r _minted-cover_letter cover_letter.aux cover_letter.bbl cover_letter.blg cover_letter.log cover_letter.out cover_letter.synctex.gz build.log >> /dev/null 2>&1
set -x
cp biblio/references.bib paper.bib

# Build the cover_letter
docker run --rm \
  --name latex \
  --entrypoint=/bin/bash \
  -v `pwd`/:/mnt \
  michaelsevilla/texlive:latest -c \
    "cd /mnt ; \
     pdflatex -synctex=1 -interaction=nonstopmode -shell-escape cover_letter; \
     bibtex cover_letter; \
     pdflatex -synctex=1 -interaction=nonstopmode -shell-escape cover_letter; \
     pdflatex -synctex=1 -interaction=nonstopmode -shell-escape cover_letter;" &> build.log

ERR=$?
if [ $ERR != "0" ] ; then
  echo "ERROR: $ERR"
  cat build.log
fi

set +e
rm -r _minted-cover_letter cover_letter.aux cover_letter.bbl cover_letter.blg cover_letter.log cover_letter.out cover_letter.synctex.gz build.log >> /dev/null 2>&1

echo "SUCCESS"

