#!/bin/bash

echo -e "\n\nIf the first argument is '-v', then the following argument should be an extra directory to mount, for use with the ./cll_build -a or -A options, or 'none'." 
echo "Syntax is of podman's -v option, so to mount ~/www on /tmp/www, do: ~/www:/tmp/www"
echo -e "\nAll other arguments are passed to ./cll_build\n\n"
sleep 1

extra_dir=""
if [ "$1" = '-v' ]
then
  shift
  extra_dir="-v $1"
  shift
fi

sudo podman kill cll_build
sudo podman rm cll_build

dir=$(readlink -f $(dirname $0))

# Make it accessible to both the user and the container
chcon -R -t container_home_t  .

# FOR TESTING; forces complete podman rebuild
# sudo podman build --no-cache -t lojban/cll_build -f podmanfile .
# sudo podman rmi lojban/cll_build
sudo podman build -t lojban/cll_build -f Dockerfile . || {
  echo "Docker build failed."
  exit 1
}
sudo /bin/podman run --name cll_build --log-driver syslog --log-opt tag=cll_build \
  -v $dir:/srv/cll $extra_dir -it lojban/cll_build \
  /tmp/docker_init.sh "$(id -u)" "$(id -g)" "$@"
