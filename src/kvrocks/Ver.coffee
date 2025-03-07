#!/usr/bin/env coffee

< (redis)=>
  info = (await redis.info('server')).slice(10)
  p = info.indexOf('\r')
  return info.slice(0,p).split(":")[1]

