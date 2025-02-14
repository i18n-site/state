#!/usr/bin/env coffee

> ./conf/warn.js
  ./Ping.js
  @8v/heartbeat
  @8v/cron

KIND = 'warn'

ping = heartbeat KIND, Ping, 300

cron(
  KIND
  "* * * * *" # 定时运行
  =>
    Promise.allSettled Object.entries(warn).map ping
)

