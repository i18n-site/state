#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR

set -e
. .project.sh
set -x

./sh/env.sh

exec watchexec \
  --shell=none \
  --project-origin . -w . \
  --exts rs,toml \
  -r \
  -- bash -c "set -a && . /tmp/stateRust.env  && set +a && . .project.sh && set -ex && . .run.sh"
