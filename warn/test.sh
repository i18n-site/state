#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

curl "http://localhost:8787/__scheduled?cron=*%2F3+*+*+*+*"
