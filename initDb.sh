#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR

set -e

. conf/env/_pg.env

psql $PG_URL <pg.sql
