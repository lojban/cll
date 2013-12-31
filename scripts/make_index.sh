#!/bin/bash

IFS='
'

for line in $(cat scripts/origcllindex.txt | grep -v '^\s*#')
do
  item=$(echo $line | sed 's/[(,:].*//' | sed 's/^\s*//' | sed 's/\\/\\\\/g')
#  echo "line: $line"
#  echo "item: $item"
  count=$(grep "\<$item\>" [0-9]*.xml | wc -l)
  if [ "$count" -le 0 ]
  then
    echo "$item -- has count $count, skipping -- $line"
    continue
  fi
  if [ "$count" -ge 10 ]
  then
    echo "$item -- has count $count, skipping -- $line"
    continue
  fi

  for file in $(grep -l "\<$item\>" [0-9]*.xml)
  do
#    echo $file
    sed -i "/\<$item\>/s|$|\n<!-- ^^ $line -->\n<indexterm><primary>$item</primary></indexterm>|" $file
  done
done
