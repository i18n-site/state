#!/usr/bin/env coffee

> ./app.js
  @hono/node-server > serve

port = 8080

console.log 'http://127.0.0.1:'+port

serve({
  fetch: app.fetch
  port
})

