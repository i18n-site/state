#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR

set -e
. sh/project.sh
set -x

rm -rf lib
cf2js="bun x cep -c src/$project -o lib/$project"

$cf2js

deno run -A lib/$project/test.js
