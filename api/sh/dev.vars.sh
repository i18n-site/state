#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*/*}
cd $DIR
set -ex

cat \
  ../conf/env/_*.env \
  ../conf/env/cf*.env >cf/.dev.vars
