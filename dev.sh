#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR

set -e
. sh/project.sh
set -x

rm -rf lib
cf2js="bun x cep -c src/$project -o lib/$project"

$cf2js

# 'nodemon -w lib -e js -x lib/main.js' \
exec mise exec -- bun x concurrently --names "src,app" \
  "$cf2js -w" \
  "./sh/run.sh --watch lib/$project/main.js"
