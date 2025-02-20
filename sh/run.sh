#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*/*}
cd $DIR
set -e

set -a
. conf/env/_pg.env
. conf/env/_apiToken.env
. conf/env/denoNotifyApi.env
set +a

set -x

exec deno --unstable-cron -A $@
