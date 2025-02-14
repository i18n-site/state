#!/usr/bin/env coffee

> ./conf/mysql.js
  ./Ping.js
  @8v/heartbeat
  @8v/cron

KIND = 'mysql'

ping = heartbeat KIND, Ping, 300

cron(
  KIND
  "* * * * *" # 定时运行
  =>
    Promise.allSettled Object.entries(mysql).map ping
)

