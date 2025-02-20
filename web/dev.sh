#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

rm -rf htm

mkdir -p htm

rsync -av public/ htm/

bun x concurrently --name "pug,srv" \
  "pug -w -c src -o htm" \
  "bun run serve"
