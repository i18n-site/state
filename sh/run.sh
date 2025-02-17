#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*/*}
cd $DIR
set -e

set -a
. conf/env/api.cf.env
. conf/env/src.env
set +a

set -x

exec deno --unstable-cron -A $@
