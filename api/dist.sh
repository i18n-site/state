#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR

. ../../conf/state/api/cloudflare.sh

set -ex

bun x cf_work_secret -d cf

rm -rf cf/src
bun x cep -c src -o cf/src

mise exec -- ./sh/mergePackage.coffee

cd cf
bun i
bun x wrangler deploy
