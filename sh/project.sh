#!/usr/bin/env bash

if [ ${#1} -eq 0 ]; then
  if [ -f ".dev" ]; then
    project=$(cat .dev)
  else
    echo "❯ $0 project"
    exit 1
  fi
else
  project=$(basename $1)
  if [ ! -d "src/$project" ]; then
    echo "src/$project NOT EXIST"
    exit 1
  fi
  echo $project >.dev
fi
