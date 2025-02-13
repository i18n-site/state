#!/usr/bin/env coffee

> hono > Hono
  ./cron.js
  ./STATE.js > OK ERR

app = new Hono()

app.get(
  '/'
  (c) =>
    c.json([
      OK
      ERR
    ])
)

app.get(
  '/ping'
  (c)=>
    c.text('')
)

cron()

setInterval cron, 6e4

export default app
