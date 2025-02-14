> ./state.js
  ./ping.js
  postgres
  @3-/pg/pgConf.js
  hono > Hono
  @8v/honobind

pgConn = (env)=>postgres(...pgConf(env))
app = new Hono()

honobind(app).get({
  ping
})

export default app


