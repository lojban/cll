#!/bin/sh

testing=""
if [ "$1" = "-t" ]
then
  testing=1
  shift
  echo "Entering testing mode: no actual definition work will be done." >&2
fi

TMPFILE="/tmp/generate_glossary.tmp.$$"

IFS='
'
initial=''
indiv=''

xsltproc --nonet --path . --novalid xml/generate_glossary.xsl cll_preglossary.xml | grep -P '\t' | sort | uniq >$TMPFILE

for line in $(cat $TMPFILE)
do
  if [ ! "$initial" ]
  then
    cat <<EOF
<glossary>
<title>Lojban Word Glossary</title>
<para>All definitions in this glossary are brief and unofficial.
Only the published dictionary is a truly official reference for word
definitions.  These definitions are here simply as a quick reference.
</para>

<!-- THIS FILE IS AUTOGENERATED.  DO NOT EDIT OR CHECK IN! -->

EOF
  fi

  slug=$(echo $line | awk -F'\t' '{ print $1 }')
  word=$(echo $line | awk -F'\t' '{ print $2 }' | sed 's/\.//g')
  #  echo "$slug--$word"
  newinitial=$(echo $word | cut -c 1)

  if [ "$initial" != "$newinitial" ]
  then
    if [ "$indiv" ]
    then
      echo "</glossdiv>"
    else
      indiv=1
    fi
    echo "<glossdiv><title>$newinitial</title>"
    initial=$newinitial
  fi

  if [ "$testing" ]
  then
    definition="placeholder definition"
  else
    if [ ! -f jbovlaste.xml -o "$(find jbovlaste.xml -mtime +1)" ]
    then
      echo "jbovlaste file is old; refetching." 1>&2
      wget 'http://jbovlaste.lojban.org/export/xml-export.html?lang=en&bot_key=z2BsnKYJhAB0VNsl' -O jbovlaste.xml
    fi

    rm jbovlaste2.xml
    grep '^<valsi word=' jbovlaste.xml | \
      sed 's/^<valsi word="\([^"]*\)" /###\1### &/' >jbovlaste2.xml

    definition=$(grep -F "###$word### " jbovlaste2.xml | \
        sed -e 's/^[^ ]* //' | \
        sed -e 's/.*<definition>//' -e 's;</definition>.*;;' | \
        sed -e 's/\&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g' | \
        sed 's/\s\s*/ /g' | \
        # This LaTeX handling is pretty horrible; should probably write a real loop in Perl or something.
        # Turn LaTeX stuff into xml: $1*10^{-2}$]
        sed 's;\$\(1\*\)\?10^{\?\([^}$]*\)}\?\$;<inlinemath>\110<superscript>\2</superscript></inlinemath>;g' | \
        # Turn LaTeX stuff into xml: $x_{1}$
        sed 's;\$\([a-z][a-z]*\)_{\?\(.\)}\?\$;<inlinemath>\1<subscript>\2</subscript></inlinemath>;g' | \
        # Turn LaTeX stuff into xml: $x_2=b_1$
        sed 's;\$\([a-z][a-z]*\)_{\?\(.\)}\?=\([a-z][a-z]*\)_{\?\(.\)}\?\$;<inlinemath>\1<subscript>\2</subscript>=\3<subscript>\4</subscript></inlinemath>;g' | \
        # Turn LaTeX stuff into xml: $x_2=b_1=t_2$
        sed 's;\$\([a-z][a-z]*\)_{\?\(.\)}\?=\([a-z][a-z]*\)_{\?\(.\)}\?=\([a-z][a-z]*\)_{\?\(.\)}\?\$;<inlinemath>\1<subscript>\2</subscript>=\3<subscript>\4</subscript></inlinemath>;g'
      )

    if [ "$(echo $definition | grep -E '(\$|\\)')" ]
    then
      echo "UNHANDLED LATEX in definiton for $word: $definition"
    fi

    if [ ! "$(echo $definition | sed 's/\s*//g')" ]
    then
      definition="NO JBOVLASTE DEFINITION FOR \"$word\" FOUND!"
      echo $definition 1>&2
    fi
  fi

  cat <<EOF
<glossentry xml:id="valsi-$slug">
<glossterm>$word</glossterm>
<glossdef>
  <para>$definition</para>
</glossdef>
</glossentry>
EOF
done

if [ "$initial" ]
then
  cat <<EOF

</glossdiv>
</glossary>

EOF
fi

rm $TMPFILE
