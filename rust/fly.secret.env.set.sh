#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR

set -ex

exec bash -c "flyctl secrets set $(cat ../conf/rust/*.env | grep -v "^#" | tr '\n' ' ')"
