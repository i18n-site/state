#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

set -e
. .project.sh
set -x

set +a

for f in ../conf/rust/*.env; do
  . $f
done

set -a

exec ./.run.sh $project
