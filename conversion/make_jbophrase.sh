#!/bin/sh

IFS='
'

for line in $(cat scripts/lojban_quotes)
do
  echo "line: $line"
  fixed=$(echo $line | sed 's/\./\\./g')
  sed -i "s;<quote>$fixed</quote>;<jbophrase>$fixed</jbophrase>;g" [0-9]*.xml 
done
