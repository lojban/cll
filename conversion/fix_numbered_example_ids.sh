#!/bin/sh

IFS='
'

for line in $(xsltproc --nonet --path . --novalid find_example_ids.xsl cll.xml | grep random-id)
do
  randomid=$(echo $line | awk '{ print $1 }')
  numberedid=$(echo $line | awk '{ print $2 }')

  echo "$randomid -- $numberedid"

  sed -i "s/\"$numberedid\"/\"$randomid\"/g" [0-9]*.xml
done
