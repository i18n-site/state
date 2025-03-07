#!/usr/bin/env coffee

> ./run.js
  ./Ping.js
  ./PingSentinel.js
  ./conf/kvrocks.js:KVROCKS > SENTINEL

await Promise.allSettled [
  run(
    ([name, host_li])=>
      PingSentinel(host_li)
    SENTINEL
  )
  run(
    ([name, host_li])=>
      Ping(host_li)
    KVROCKS
  )
].map (f)=>f()

process.exit()

