#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

curl "http://127.0.0.1:8787/$@"
#/__scheduled?cron=*%2F3+*+*+*+*"
