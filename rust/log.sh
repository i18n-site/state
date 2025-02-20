#!/usr/bin/env bash

DIR=$(realpath $0) && DIR=${DIR%/*}
cd $DIR
set -ex

# exec fly logs | cut -d ']' -f 3-
exec fly logs | node --input-type=module -e \
  'for await (let c of process.stdin){
for(let i of c.toString().split("\n")){
  if(i){
    const ts = i.slice(9, 20).replace("T"," "), remain = i.slice(21);
    console.log(ts, remain.slice(remain.indexOf("]",1+remain.indexOf("]"))+1 ).trimStart())
  }
}
}'
