#!/usr/bin/env coffee

> ansis > redBright red gray

export default (kind, group, item, err)=>
  tip = [
    '❌'
    kind
    group
    '> ' + item
  ]

  console.error(
    red(tip.join(' '))
    gray ':'
    redBright(err)
  )
  return
