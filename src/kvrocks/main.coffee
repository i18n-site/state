#!/usr/bin/env coffee

> ./Ping.js
  ./PingSentinel.js
  @8v/heartbeat
  @8v/cron
  ./run.js
  ./conf/kvrocks.js:KVROCKS > SENTINEL

KIND = 'kvrocks'

RUN_LI = [
  [
    KIND, Ping, KVROCKS
  ]
  [
    'redis-sentinel', PingSentinel, SENTINEL
  ]
].map ([kind, ping, conf])=>
  run(
    heartbeat kind, ping, 300
    conf
  )

cron(
  KIND
  "* * * * *" # 定时运行
  =>
    Promise.allSettled RUN_LI.map (f)=>f()
)

