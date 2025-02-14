#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR

set -e

. conf/env/api.cf.env

psql $PG_URL <pg.sql
