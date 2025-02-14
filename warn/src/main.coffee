> ./state.js
  postgres
  @3-/pg/pgConf.js
  hono > Hono

pgConn = (env)=>postgres(...pgConf(env))
app = new Hono()
app.get('/', (c) => c.text('Hello Cloudflare Workers!'))

export default app


