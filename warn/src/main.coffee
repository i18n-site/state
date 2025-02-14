> ./state.js
  ./ping.js
  postgres
  @3-/pg/pgConf.js
  hono > Hono

pgConn = (env)=>postgres(...pgConf(env))
app = new Hono()

do =>
  for [path, func] from Object.entries({
    ping
  })
    app.get(
      '/'+path,
      (c)=>
        r = await func(c)
        if r
          if r.constructor == String
            return c.text(r)
          return r
        return c.text('')
    )
  return


export default app


