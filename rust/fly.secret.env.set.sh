#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR

set -ex

./sh/env.sh

exec bash -c "flyctl secrets set $(cat /tmp/stateRust.env | tr '\n' ' ')"
