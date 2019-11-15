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
sudo -u cll /bin/bash -c "cd /srv/cll ; ./cll_build $*"
