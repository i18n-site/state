#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*/*}
cd $DIR
set -ex

ncu -u
bun i
if ! command -v molt &>/dev/null; then
  deno install --global --allow-all --name molt jsr:@molt/cli
fi

cd src
fd deno.jsonc -x bash -c 'DIR=$(dirname "{}") && echo -e $DIR && cd $DIR && deno outdated --update --latest && molt --no-lock --commit'

cd ../api
ncu -u
bun i

cd ../rust
./sh/upgrade.sh
