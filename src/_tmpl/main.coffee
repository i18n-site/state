#!/usr/bin/env coffee

> ./Ping.js
  @8v/heartbeat
  @8v/cron
  ./run.js

KIND = '_tmpl'

ping = heartbeat KIND, Ping, 300

cron(
  KIND
  "* * * * *" # 定时运行
  =>
    run(ping)
)

