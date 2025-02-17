#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

if ! command -v deployctl &>/dev/null; then
  deno install -A jsr:@deno/deployctl --global
fi
