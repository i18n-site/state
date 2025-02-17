#!/usr/bin/env coffee

< (map, key)=>
  val = map[key]
  if not val
    map[key] = val = new Set
  return val
