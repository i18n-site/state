#!/usr/bin/env bash

cd $project

if [ -f "test.sh" ]; then
  exec ./test.sh
else
  exec cargo run
fi
