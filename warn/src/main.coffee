> # ./cron.js
  # ./initSend.js
  ./state.js
  postgres
  @3-/pg/pgConf.js
  # @3-/pg/genfunc.js
  @8v/heartbeat

pgConn = (env)=>postgres(...pgConf(env))

export default {
  fetch: (req, env)=>state(
      req
      env
      pgConn(env)
    )

  # scheduled : (event, env, ctx) =>
  #   initSend(env)
  #   pg = pgConn(env)
  #   await heartbeat(
  #     pg
  #     600
  #     'warn'
  #     'cf'
  #     cron
  #     [
  #       env
  #       genfunc(pg)
  #     ]
  #   )
  #   return
}

