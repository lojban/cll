#!/bin/bash

set -e

if [ ! "$1" ]
then
  echo "Give base dir as sole argument."
  exit 1
fi
basedir="$1"
builddir="$basedir/build"
epubbuilddir="$builddir/epub"
srcdir="$basedir/epub"

rm -rf $epubbuilddir/
mkdir $epubbuilddir/

# cp -pr epub/META-INF epub/content.opf epub/mimetype epub/toc.xhtml epub-temp
cp -pr $srcdir/META-INF $srcdir/mimetype $epubbuilddir/
cp -pr $builddir/epub-xhtml/* $epubbuilddir/
rm -rf $epubbuilddir/dtd
# Kindle doesn't like svg
rm -f $basedir/build/epub/media/chapter-2-diagram.svg

# Clean up HTML headers and crap to make epubchek happy
for file in $(find $epubbuilddir/ -name '*.html')
do
  sed -i -r -e '/^\s*(<!DOCTYPE|<script|<meta) /d' \
    -e 's;^\s*<[?]xml .*;<?xml version="1.0" encoding="UTF-8"?>;' \
    -e 's;^\s*<html .*;<html xmlns="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops">;' \
    -e 's;\s+summary="[^"]*";;' "$file"

  # Kindle chokes badly on dl/dt/dd nesting, so we just replace it throughout and fake it with CSS
  sed -i -r -e 's;<dl(( )class="([^"]*)")?>;<ul class="dl\2\3">;' -e 's;</dl>;</ul>;' \
    -e 's;<d([dt])(( )class="([^"]*)")?>;<li class="d\1\3\4">;' -e 's;</d[dt]>;</li>;' \
    "$file"

  grep '<d[ltd]' "$file" && echo "BAD: $file still has dl/dt/dd elements!"
done
# More of the same, it really wants a dd for every dt
cat build/epub/index.html | ruby -e 'puts STDIN.read.gsub(%r{</dt>\s*<dt>}m, "</dt><dd/><dt>").gsub(%r{</dt>\s*</dl>}m, "</dt><dd/></dl>")' > build/epub/index.html.new
mv build/epub/index.html.new build/epub/index.html

rm -f $epubbuilddir/cll.appcache

cp $srcdir/toc.xhtml.s1 $epubbuilddir/toc.xhtml
grep -P '^\s*(<a |(</?dl>|</?dt>)\s*$)' build/epub-xhtml/index.html | \
  sed -r -e 's/dt>\s*$/li>/g' -e 's/<dl>\s*$/<ol>/' -e 's;</dl>\s*$;</ol></li>;' | \
  ruby -e 'puts STDIN.read.gsub(%r{</li>\s*<ol>}m, "<ol>")' >>$epubbuilddir/toc.xhtml
cat $srcdir/toc.xhtml.s2 >>$epubbuilddir/toc.xhtml
cat $epubbuilddir/toc.xhtml | ruby -e 'puts STDIN.read.gsub(%r{</ol>\s*</li>\s*</nav>}m, "</ol>\n</nav>")' >>$epubbuilddir/toc.xhtml.tmp
mv $epubbuilddir/toc.xhtml.tmp $epubbuilddir/toc.xhtml

for file in $(find build/epub-xhtml/ -type f -name '*.html' | xargs grep -l '<h1 class="title"><a')
do
  base="$(basename $file)"
  id="$(grep '<h1 class="title"><a' $file | head -n 1 | sed -e 's/.* id="//' -e 's/".*//')"
  sed -i "s/href=\"$base\"/href=\"$base#$id\"/" $epubbuilddir/toc.xhtml
done

version="$(grep '^Version ' build/epub/index.html)"
cat $srcdir/content.opf.s1 | sed "s/REPLACEDATE/$(date -u +%Y-%m-%dT%H:%M:%SZ)/" | \
  sed "s/REPLACEVERSION/$version/" >$epubbuilddir/content.opf

cd $epubbuilddir/

for file in $(find -type f | grep -P -v '/(mimetype|toc.xhtml|final.css|content.opf|META-INF.*)$' | sed 's;^.\/;;')
do
  type=""
  if [[ $file =~ \.png$ ]]
  then
    type="image/png"
  elif [[ $file =~ \.gif$ ]]
  then
    type="image/gif"
  elif [[ $file =~ \.svg$ ]]
  then
    type="image/svg"
  elif [[ $file =~ \.html$ ]]
  then
    type="application/xhtml+xml"
  fi

  properties=""
  if grep -q '<math' $file
  then
    properties="properties=\"mathml\""
  fi

  if [ ! "$type" ]
  then
    echo "No type found for $file ; bailing."
    exit 1
  fi

  id="$(echo $file | tr -d '_./-')"
  echo "<item id=\"$id\" $properties href=\"$file\" media-type=\"$type\"/>" >>$epubbuilddir/content.opf
done

cat $srcdir/content.opf.s2 >>$epubbuilddir/content.opf

for ref in $(grep '<a ' $epubbuilddir/toc.xhtml | grep -v '#section'  | sed -r -e 's/^\s*//' -e 's;.*<a href="([^"#]*)(#[^"]*)?">.*;\1;')
do
  id="$(echo $ref | tr -d '_./-')"
  echo "<itemref linear=\"yes\" idref=\"$id\"/>" >>$epubbuilddir/content.opf
done

cat $srcdir/content.opf.s3 >>$epubbuilddir/content.opf

cp $srcdir/cover.jpg $epubbuilddir/media/cover.jpg
cp $srcdir/cover.html $epubbuilddir/cover.html

rm -f $basedir/build/cll.epub $basedir/build/cll.mobi

zip -q -X -r $basedir/build/cll.epub mimetype *
