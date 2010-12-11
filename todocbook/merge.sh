#!/bin/sh

echo '<?xml version="1.0"?>
<!DOCTYPE book PUBLIC "-//OASIS//DTD DocBook XML V5.0//EN"
               "dtd/docbook-5.0.dtd">

<book xmlns:xlink="http://www.w3.org/1999/xlink">
' >cll.xml

for dir in $(ls .. | grep -P '^[0-9]+/?$' | sort -n | sed -e 's;/*$;;' -e 's;.*/;;')
do
  cat $dir.xml >>cll.xml
done

echo '

</book>' >>cll.xml
