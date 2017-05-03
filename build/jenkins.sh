#!/bin/bash

if [[ "$WORKSPACE" == "" ]]; then
  echo
  echo "The variable WORKSPACE needs to be defined."
  echo
  echo "Set it to the directory path of the tapestry source tree."
  echo
  exit 1
fi

docker build --tag=tapestry/test build/docker

docker run -v $WORKSPACE:/home/tapestry/tapestry tapestry/test:latest  build/test/run-tapestry-tests.sh

