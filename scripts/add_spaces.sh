#!/bin/sh

# tidy, for some reason, has a habit of *removing* spaces, so that
#
#   foo <em>bar</em> baz
#
# into:
#
#   foo <em>bar</em>baz
#
# which sucks.  You can see these with:
#
#   grep -P '/[^>]*>[^\s<.:,;)?=/!-]' [0-9]*.xml
#
# and the code here should fix them.

for file in [0-9]*.xml
do
  perl -i -pe 's;(/>|</programlisting>|</jbophrase>|</mediaobject>|</citation>|</superscript>|</indexterm>|</quote>|</cmavo-entry>|</emphasis>|</phrase>)([a-zA-Z0-9([]);$1 $2;g' $file
done
