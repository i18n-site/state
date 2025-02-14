#!/usr/bin/env coffee

> ./conf/mysql.js
  ./Ping.js
  @8v/heartbeat.js
  @8v/cron

ping = heartbeat.mysql Ping, 300

cron(
  "* * * * *" # 定时运行
  =>
    Promise.allSettled Object.entries(mysql).map ping
)

