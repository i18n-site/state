#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR

if [ -n "$1" ]; then
  export PROJECT=$1
  if [ -d "$1" ]; then
    echo "❌ $1 EXIST"
    exit 1
  fi
else
  echo "USAGE : $0 project_name"
  exit 1
fi

set -ex

cp -R _tmpl $PROJECT

cd $PROJECT

rpl _tmpl $PROJECT
rpl _Tmpl "${PROJECT^}"

git add .
