#!/bin/bash

set -e

# Find and go to where the script lives
sdir="$(dirname "$(readlink -f $0)")"
cd "$sdir"
# And step out one
cd ..

if [ ! "$1" ]
then
  echo "Give build dir as sole argument."
  exit 1
fi

builddir=$1
if [ -s 'xml/jbovlaste.xml' ]
then
  echo
  echo "Using the extant xml/jbovlaste.xml for the jbovlaste dictionary file.  If you think this is in error, run the build with -j."
  echo
else
  echo
  echo "Pulling a new xml/jbovlaste.xml from the web.  If you end up using it you should check it in so we have consistent builds."
  echo
  wget 'http://jbovlaste.lojban.org/export/xml-export.html?lang=en&bot_key=z2BsnKYJhAB0VNsl' -O 'xml/jbovlaste.xml'
fi

cp xml/jbovlaste.xml "$builddir/jbovlaste.xml.new"

sizenew="$(stat -c %s $builddir/jbovlaste.xml.new || echo 0)"
if [ ! -f "$builddir/jbovlaste.xml.new" -o ! "$sizenew" -o "$sizenew" -lt 100 ]
then
  echo
  echo "Couldn't fetch jbovlaste file; bailing."
  echo
  exit 1
fi

size="$(stat -c %s $builddir/jbovlaste.xml || echo 0)"
if [ ! -f "$builddir/jbovlaste.xml" -o ! "$size" -o "$size" -lt 100 ]
then
  echo
  echo "old jbovlaste build file is bad; replacing"
  echo
  mv "$builddir/jbovlaste.xml.new" "$builddir/jbovlaste.xml"
else
  if diff -q "$builddir/jbovlaste.xml.new" "$builddir/jbovlaste.xml" >/dev/null 2>&1
  then
    echo
    echo "jbovlaste file has not changed."
    echo
  else
    echo
    echo "New jbovlaste file found; putting in place."
    echo
    cp "$builddir/jbovlaste.xml.new" "$builddir/jbovlaste.xml"
  fi
fi
