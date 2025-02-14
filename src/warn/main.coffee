#!/usr/bin/env coffee

> ./Ping.js
  @8v/heartbeat/kind.js:heartbeat
  @8v/cron

KIND = 'warn'

# await Ping()

cron(
  KIND
  "* * * * *" # 定时运行
  heartbeat KIND, Ping, 300
)

