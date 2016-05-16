#!/bin/bash

cd $1

# Conveniently, all the HTML we produce is in a flat directory
# structure, so making HTML5 app cache manifest files is actually
# pretty trivial.

rm cll.appcache
touch cll.appcache
echo 'CACHE MANIFEST' >>cll.appcache
echo "# $(date)" >>cll.appcache
find . -type f | sed 's;^\./;;' | grep -v '\.appcache' >>cll.appcache

find . -type f | xargs grep -l '<html xmlns=' | while read file
do
  sed -i 's;<html xmlns=;<html xml:lang="en" lang="en" xmlns:mml="http://www.w3.org/1998/Math/MathML" manifest="cll.appcache" xmlns=;' "$file"
done
