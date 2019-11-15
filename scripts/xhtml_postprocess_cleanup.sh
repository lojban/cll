#!/bin/bash

set -x

MAINDIR=$(pwd)

cufile=$MAINDIR/scripts/xhtml_postprocess_cleanup_file.rb
if [[ ! -f $cufile ]]
then
  echo "Can't find $cufile"
fi
cd $1

find . -type f | xargs grep -l '<html xmlns=' | while read file
do
  # It's important here that when we're done, the files still match
  # "<html xmlns=", so the cleanup scripts can be composable
  sed -r -i 's;<html xmlns=([^> ]*);<html xmlns=\1 xml:lang="en" lang="en";' "$file"
  # Stop going out to the web all the time
  sed -r -i 's; "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">; "dtd/xhtml1-transitional.dtd">;' "$file"
  ruby $cufile "$file" >"$file.tmp"
  mv "$file.tmp" "$file"
  xmllint --format "$file" >"$file.tmp"
  mv "$file.tmp" "$file"
done
