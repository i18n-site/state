#!/usr/bin/env coffee

> ./run.js
  ./Ping.js

await run ([name, host_li])=>
  console.log name, host_li
  Ping(host_li)

process.exit()

