#!/bin/bash

docker build --tag=tapestry/test build/docker

docker run -v $WORKSPACE:/home/tapestry/tapestry tapestry/test:latest  build/test/run-tapestry-tests.sh
