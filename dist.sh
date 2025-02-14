#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR

set -e
. sh/project.sh
set -x

mise trust

# mise exec -- ./gen.coffee

rm -rf lib

lib=lib/$project

bun x cep -c src/$project -o $lib

cd $lib

DIR_ENV=$DIR/conf/env

cat $DIR_ENV/api.cf.env $DIR_ENV/src.env >/tmp/state.env

deployctl deploy --save-config=false --force --prod \
  --env-file=/tmp/state.env

set +x

case $(uname) in
Darwin*)
  open "https://$(cat deno.jsonc | jq -r '.deploy.project').deno.dev"
  ;;
  # Linux*)
  #   ;;
  # *)
  #   ;;
esac
