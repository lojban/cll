#!/bin/sh

randnum=0

for file in [0-9]*.xml.orig
do
  short=$(echo $file | sed 's/\.orig$//')

  echo "*********************************************************** $short"

  cat $short.orig | make_cmavo.pl | \
    tidy -config massage.tidy -xml - | \
    sed -e '/xml version/d' -e '/DOCTYPE book PUBLIC/d' -e '/docbook-5.0.dtd/d' > $short

done
