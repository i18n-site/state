#!/usr/bin/env coffee

> ./conf/mysql.js
  ./Ping.js
  @8v/send/init.js:
  @8v/heartbeat/wrap.js

KIND = 'mysql'

ping = wrap 300, KIND, Ping

Deno.cron(
  KIND
  "* * * * *"
  =>
    Promise.allSettled Object.entries(mysql).map ping
)

Deno.serve =>
  new Response(KIND)

