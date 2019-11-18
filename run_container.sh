#!/bin/bash

CONTAINER_BIN=${CONTAINER_BIN:-$(which podman 2>/dev/null)}
CONTAINER_BIN=${CONTAINER_BIN:-$(which docker 2>/dev/null)}

# Try sudo first because systems where everything is working without
# sudo are less likely
if sudo $CONTAINER_BIN info >/dev/null 2>&1
then
  CONTAINER_BIN="sudo $CONTAINER_BIN"
else
  if $CONTAINER_BIN info >/dev/null 2>&1
  then
    # Everything is working; no-op
    CONTAINER_BIN="$CONTAINER_BIN"
  else
    echo "I can't get a working container system.  You need to either have podman (preferred) or docker installed and running for this build system to work.  I have tried both \"podman info\" and \"docker info\", with and without sudo."
    exit 1
  fi
fi

# Manually pull any -a or -A arguments so we can use them to build
# volume-sharing options into our container run call.  This assumes
# arguments are well-formed; *shrug*
args=( "$@" )
extra_vols=()
extra_dirs=()
for index in ${!args[@]}
do
  arg=${args[$index]}
  if [ "$arg" = '-a' -o "$arg" = '-A' ]
  then
    nextarg=${args[$index+1]}
    nextargfile="/tmp/$(echo "${args[$index+1]}" | tr -c 'a-zA-Z0-9-' '_' | sed -e 's/^_*//' -e 's/_*$//' )"
    extra_vols+=("-v" "$nextarg:$nextargfile")
    extra_dirs+=("$nextarg")
    args[$index+1]="$nextargfile"
  fi
done

$CONTAINER_BIN kill cll_build >/dev/null 2>&1
$CONTAINER_BIN rm cll_build >/dev/null 2>&1

dir=$(readlink -f $(dirname $0))

# If SELinux is on
if which getenforce >/dev/null 2>&1 && getenforce | grep -q Enforcing
then
  # Make it accessible to both the user and the container
  chcon -R -t container_home_t  . "${extra_dirs[@]}"
fi

# FOR TESTING; forces complete container rebuild
# $CONTAINER_BIN build --no-cache -t lojban/cll_build -f Dockerfile .
# $CONTAINER_BIN rmi lojban/cll_build
echo "Running container image build; this may take a while."
echo
$CONTAINER_BIN build -t lojban/cll_build -f Dockerfile . >/tmp/rc.$$ 2>&1 || {
  echo "Container image build failed.  Here's the output: "
  echo
  cat /tmp/rc.$$
  echo
  echo
  echo "Container image build failed.  Output is above."
  echo
  echo
  rm -f /tmp/rc.$$
  exit 1
}

rm -f /tmp/rc.$$

$CONTAINER_BIN run --name cll_build \
  -v $dir:/srv/cll "${extra_vols[@]}" -it lojban/cll_build \
  /tmp/container_init.sh "$(id -u)" "$(id -g)" "${args[@]}"
