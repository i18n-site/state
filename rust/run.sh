#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR

set -e
. .project.sh

for f in ../conf/rust/*.env; do
  set -a
  . $f
  set +a
done

set -x

echo $SMTP_HOST_LI
exec ./.run.sh $project
