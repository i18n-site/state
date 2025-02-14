#!/usr/bin/env coffee

> ./conf/warn.js
  ./Ping.js
  @8v/heartbeat
  @8v/cron

KIND = 'warn'


cron(
  KIND
  "* * * * *" # 定时运行
  heartbeat KIND, Ping, 300
)

