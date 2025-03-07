#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

. ../sh/pid.sh

./sh/dev.vars.sh

exec mise exec -- \
  bun x concurrently --names "js,cf" \
  'bun x cep -w -c src -o cf/src' './cf/dev.sh'
