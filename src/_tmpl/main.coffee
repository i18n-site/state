#!/usr/bin/env coffee

> ./conf/_tmpl.js
  ./Ping.js
  @8v/heartbeat
  @8v/cron

KIND = '_tmpl'

ping = heartbeat KIND, Ping, 300

run = =>
  Promise.allSettled Object.entries(_tmpl).map ping

# for dev test
# await run()

cron(
  KIND
  "* * * * *" # 定时运行
  run
)

