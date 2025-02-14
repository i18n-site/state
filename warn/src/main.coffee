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
        try
          r = await func(c)
        catch err
          c.status(500)
          r = err
        if r
          if r.constructor == String
            return c.text(r)
          return r
        return c.text('')
    )
  return


export default app


