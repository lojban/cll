#!/bin/sh

chapter=$(echo $1 | sed -e 's;/*$;;' -e 's;.*/;;')
echo "chapter: $chapter"

# Make the chapter header
sed -n '1,/<\/h2>/p
/<\/body>/,$p' $1/1/index.html | \
  sed '/<div/,/<hr \/>/d' >/tmp/glom.out

tidy -quiet -config fix.tidy /tmp/glom.out >/tmp/glom.out2

xsltproc --path dtd/ --nonet --stringparam filename /tmp/glom.out2 \
  --stringparam prefix cll html2docbook.xslt /tmp/glom.out2 \
  > /tmp/glom.out3

rm $chapter.xml
touch $chapter.xml

sed "s;<section xmlns:xlink=\"http://www.w3.org/1999/xlink\" xml:id=\"cll_/tmp/glom.out2\">;<chapter xml:id=\"cll_chapter$chapter\">;" /tmp/glom.out3 | \
sed '/<?xml version="1.0"?>/d' | \
sed 's;</section>;;' >>$chapter.xml
echo >>$chapter.xml

for suffix in $(find $1 -type f -name '*.html' | sed -e "s;^$1/*;;" | sort -t/ -k1n)
do
  file="$1$suffix"
  echo $file
  section=$(echo $file | sed -e "s;^$1/*;;" -e "s;/.*;;")
  echo s: $section

  tidy -quiet -config fix.tidy $file >/tmp/glom.out
  perl munge.pl /tmp/glom.out $chapter $section >/tmp/glom.out2

  # Debugging
  # cp /tmp/glom.out2 $chapter-$section.munged

  xsltproc --maxdepth 512 --path dtd/ --nonet --stringparam filename /tmp/glom.out2 \
    --stringparam prefix cll html2docbook.xslt /tmp/glom.out2 \
    > /tmp/glom.out3

  sed "s;<section xmlns:xlink=\"http://www.w3.org/1999/xlink\" xml:id=\"cll_/tmp/glom.out2\">;<section xml:id=\"cll_chapter$chapter-section$section\">;" /tmp/glom.out3 | \

  # Fix up labels
  sed 's;<anchor xml:id="cll_yacc-\([^"]*\)"/>;<anchor xreflabel="YACC rule #\1" xml:id="cll_yacc-\1"/>;g' | \
  sed 's;<anchor xml:id="cll_bnf-\([^"]*\)"/>;<anchor xreflabel="BNF rule #\1" xml:id="cll_bnf-\1"/>;g' | \

  sed '/<?xml version="1.0"?>/d' >>$chapter.xml
  echo >>$chapter.xml

  rm /tmp/glom.out /tmp/glom.out2 /tmp/glom.out3
done

echo "
</chapter>" >>$chapter.xml
