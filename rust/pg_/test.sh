#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

cd ..
. env.sh
cd $DIR
cargo test --all-features -- --nocapture
