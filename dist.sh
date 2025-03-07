#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR

set -e
. sh/project.sh
. conf/projectPrefix.sh
set -x

mise trust

# mise exec -- ./gen.coffee

cd src/$project
deno fmt
deno lint

cd $DIR

rm -rf lib

lib=lib/$project

bun x cep -c src/$project -o $lib

cd $lib

DIR_ENV=$DIR/conf/env

bun x envexpand \
  $DIR_ENV/_apiToken.env \
  $DIR_ENV/_pg.env \
  $DIR_ENV/denoNotifyApi.env >/tmp/state.env

deployctl deploy \
  --project=${PROJECT_PREFIX}$project \
  --save-config=false \
  --force --prod \
  --env-file=/tmp/state.env
