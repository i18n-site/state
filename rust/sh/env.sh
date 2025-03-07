#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*/*}
cd $DIR
set -ex

DIR_ENV=$(dirname $DIR)/conf/env

TMP=/tmp/stateRust.env

bun x envexpand $(ls ../conf/rust/*.env | sort) >$TMP
