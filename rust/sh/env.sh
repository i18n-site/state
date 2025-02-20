#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*/*}
cd $DIR
set -ex

DIR_ENV=$(dirname $DIR)/conf/env

TMP=/tmp/stateRust.env
cat ../conf/rust/*.env | grep -v "^#" >$TMP.tmp

bun x envexpand \
  $DIR_ENV/_apiToken.env \
  $DIR_ENV/_pg.env \
  $DIR_ENV/denoNotifyApi.env \
  $TMP.tmp >$TMP

rm $TMP.tmp
