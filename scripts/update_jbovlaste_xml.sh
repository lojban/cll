#!/bin/bash

set -e

if [ ! "$1" ]
then
  echo "Give build dir as sole argument."
  exit 1
fi

builddir=$1
wget 'http://jbovlaste.lojban.org/export/xml-export.html?lang=en&bot_key=z2BsnKYJhAB0VNsl' -O "$builddir/jbovlaste.xml.new"

sizenew="$(stat -c %s $builddir/jbovlaste.xml.new || echo 0)"
if [ ! -f "$builddir/jbovlaste.xml.new" -o ! "$sizenew" -o "$sizenew" -lt 100 ]
then
  echo "Couldn't fetch jbovlaste file; bailing."
  exit 1
fi

size="$(stat -c %s $builddir/jbovlaste.xml || echo 0)"
if [ ! -f "$builddir/jbovlaste.xml" -o ! "$size" -o "$size" -lt 100 ]
then
  echo "old jbovlaste file is bad; replacing"
  mv "$builddir/jbovlaste.xml.new" "$builddir/jbovlaste.xml"
else
  if diff -q "$builddir/jbovlaste.xml.new" "$builddir/jbovlaste.xml" >/dev/null 2>&1
  then
    echo "jbovlaste file has not changed."
  else
    echo "New jbovlaste file found; putting in place."
    cp "$builddir/jbovlaste.xml.new" "$builddir/jbovlaste.xml"
  fi
fi
