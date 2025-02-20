#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR

set -e
. .project.sh
./sh/env.sh

set -a
. /tmp/stateRust.env
set +a

set -x

. ./.run.sh
