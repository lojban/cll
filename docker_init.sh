#!/bin/bash

if [ ! "$1" ]
then
  echo "First argument should be the userid.  This should be automatic if you're using the run scripts."
  exit 1
fi

uid=$1
shift

if [ ! "$1" ]
then
  echo "Second argument should be the group.  This should be automatic if you're using the run scripts."
  exit 1
fi

gid=$1
shift

groupadd -g $gid cll
useradd -g $gid -u $uid -m cll

# /tmp/cll_build "$@"

cd /srv/cll
if [ -f xml/docbook-xsl-1.78.1.zip \
  -a "$(md5sum xml/docbook-xsl-1.78.1.zip 2>&1)" = '51ed42fe67ed513763c5bd9f1abd680b  xml/docbook-xsl-1.78.1.zip' ]
then
  echo "xsl already downloaded; if you think this is in error, delete xml/docbook-xsl-1.78.1.zip"
else
  sudo -u cll rm -rf xml/docbook-xsl-1.78.1*
  # it would be best not to go to a specific mirror like this, but
  # it's not obivous how to fix that
  sudo -u cll wget https://superb-sea2.dl.sourceforge.net/project/docbook/docbook-xsl/1.78.1/docbook-xsl-1.78.1.zip 
fi

if [ -d xml/docbook-xsl-1.78.1 -a "$(find xml/docbook-xsl-1.78.1 | sort | wc -l 2>&1)" = '1945' ]
then
  echo "xsl already unpacked; if you think this is in error, delete xml/docbook-xsl-1.78.1/ and/or xml/docbook-xsl-1.78.1.zip"
else
  sudo -u cll rm -rf xml/docbook-xsl-1.78.1/
  sudo -u cll bash -c "cd xml/ ; unzip docbook-xsl-1.78.1.zip"
fi

sudo -u cll /bin/bash -c "cd /srv/cll ; ./cll_build $*"
