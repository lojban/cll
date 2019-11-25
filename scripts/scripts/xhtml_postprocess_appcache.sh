#!/bin/bash

cd $1

# Conveniently, all the HTML we produce is in a flat directory
# structure, so making HTML5 app cache manifest files is actually
# pretty trivial.

rm cll.appcache
touch cll.appcache
echo 'CACHE MANIFEST' >>cll.appcache
echo "# $(date)" >>cll.appcache
echo "" >>cll.appcache
echo "CACHE:" >>cll.appcache
find . -type f | sed 's;^\./;;' | grep -v '\.appcache' | sort >>cll.appcache
echo "" >>cll.appcache
echo "NETWORK:" >>cll.appcache
echo "*" >>cll.appcache

find . -type f | xargs grep -l '<html xmlns=' | while read file
do
  # It's important here that when we're done, the files still match
  # "<html xmlns=", so the cleanup scripts can be composable
  sed -r -i 's;<html xmlns=([^> ]*);<html xmlns=\1 manifest="cll.appcache";' "$file"
  xmllint --format "$file" >"$file.tmp"
  mv "$file.tmp" "$file"
done
