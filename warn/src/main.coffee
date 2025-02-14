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
    console.log path
    app.get('/'+path, func)
  return


export default app


