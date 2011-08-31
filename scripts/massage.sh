#!/bin/sh

randnum=0

for file in [0-9]*.xml.orig
do
  short=$(echo $file | sed 's/\.orig$//')

  echo "*********************************************************** $short"

  xsltproc --path . --novalid make_examples.xsl $file | \
    sed -e 's/<jbo>[0-9.]*)*\s*/<jbo>/g' > $short.tmp

  randnum=$(./insert_ids.pl $short.tmp $short.tmp.2 $randnum)

  while ! diff -q $short.tmp $short.tmp.2 >/dev/null
  do
    mv $short.tmp.2 $short.tmp
    cat $short.tmp | sed 's;“\([^”]*\)”;<quote>\1</quote>;' | sed "s;’;';g" | sed 's;—;-;g' > $short.tmp.2
  done

  mv $short.tmp.2 $short.tmp

  tidy -config massage.tidy -xml $short.tmp | \
    sed -e '/xml version/d' -e '/DOCTYPE book PUBLIC/d' -e '/docbook-5.0.dtd/d' > $short

done
