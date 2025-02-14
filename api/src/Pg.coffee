#!/usr/bin/env coffee

> postgres
  @3-/pg/pgConf.js

export default (env)=>postgres(...pgConf(env))
