#!/bin/sh

for dir in $(ls .. | grep -P '^[0-9]+/?$' | sort -n | sed -e 's;/*$;;' -e 's;.*/;;')
do
  ./glom.sh ../$dir/ 2>&1 | grep -v 'Attempt to load network entity' | grep -v '^s: [0-9]*$'
done
