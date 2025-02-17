#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR

set -e
. .project.sh

set +a
for f in ../conf/rust/*.env; do
  . $f
done
set -a

set -x
exec ./.run.sh $project
