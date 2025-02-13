#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*/*}
cd $DIR
set -e

set -a
. conf/env/state.env
set +a

set -x

exec deno --unstable-cron -A $@
