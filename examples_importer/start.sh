#!/bin/bash

docker kill cll_examples_importer ; docker rm cll_examples_importer

docker build -t cll_examples_importer .

docker run \
  -it \
  --name cll_examples_importer \
  --memory 2g \
  --userns=keep-id \
  --log-opt max-size=1m --log-opt max-file=1 \
  -v $(pwd)/../dictionary:/cll_examples_importer/dictionary \
  -v $(pwd)/src:/cll_examples_importer/src \
  cll_examples_importer
